USE [Orchard_ap_staging];
GO
/****** Object:  StoredProcedure [dbo].[p_load_ap_data]    Script Date: 9/6/2022 12:31:52 PM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- ===============================================================
-- Author:		Terry Hawkins
-- Create date: 11/1/2022
-- Description:	loads HL7 AP results from Orchard Harvest
-- Returns:
--     0             Okay
--   -1 thru -99     Reserved by sql server for system errors
--    -100           Illegal null value passed into procedure
--    -101           General error
--    -102           CHANGE RECORD REQUEST ERROR
--    @@error        SQL errors
--
-- Note: hl7_import_log import_status:
--	1 == import okay
--  2 == animal not found in master table 
-- other == SQL server error number
--
-- Hard coded to use the hl7_admin userId
--
-- Changes:
--
-- =================================================================

DROP PROCEDURE  [dbo].[p_load_ap_data];
go

CREATE PROCEDURE [dbo].[p_load_ap_data]
(@MessageId VARCHAR(50))
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
	-- SET ANSI_WARNINGS OFF
	-- Suppress: Warning: Null value is eliminated by an aggregate or other SET operation.
	SET ANSI_WARNINGS OFF; 
    SET NOCOUNT ON;
    DECLARE @error INTEGER,
            @errormsg VARCHAR(MAX),
            @animal_id VARCHAR(7),
			@msgCursor CURSOR,
			@ctr INT,
            @hl7_message_text VARCHAR(MAX),
            @hl7_message_control_id VARCHAR(50),
            @hl7_result_status VARCHAR(10),
            @hl7_species VARCHAR(50),
            @hl7_observation_date_tm DATETIME,
            @patient_id VARCHAR(32),
            @container UNIQUEIDENTIFIER,
			@maxRecords INT,
			@obr_object_id UNIQUEIDENTIFIER,
			@accessionNumber VARCHAR(40)



    SET @animal_id = NULL;
    SET @hl7_message_text = 'Could not read message text.';
    SET @hl7_message_control_id = '';
    SET @hl7_result_status = '';
    SET @hl7_species = '';
    SET @hl7_observation_date_tm = '01-01-1900 00:00';


	-- Table variable to hold OBR records
	DECLARE @obr_data AS TABLE 
	(
		MESSAGE_ID [VARCHAR](50) NOT NULL,
		MESSAGE_CONTROL_ID [VARCHAR](50) NOT NULL,
		IDX [INT] NOT NULL,
		ANIMAL_ID [VARCHAR](30) NOT NULL,
		VERIFIED_DATE_TM [DATETIME] NULL,
		REQUESTED_DATE_TM [DATETIME] NULL,
		OBSERVATION_DATE_TM [DATETIME] NULL,
		SPECIMEN_RECEIVED_DATE_TM [DATETIME] NULL,
		PV1_VISIT_NUM [VARCHAR](50) NULL,
		SET_ID [VARCHAR](20) NOT NULL,
		SPECIMEN_NUM [VARCHAR](50) NULL,
		PROCEDURE_ID [VARCHAR](50) NULL,
		PROCEDURE_NAME [VARCHAR](50) NULL,
		PRIORITY [VARCHAR](10) NULL,
		RESULT_STATUS [VARCHAR](10) NULL,
		TECHNICIAN_FIRST_NAME [VARCHAR](50) NULL,
		TECHNICIAN_LAST_NAME [VARCHAR](50) NULL,
		OBJECT_ID [UNIQUEIDENTIFIER] NOT NULL,
		CHARGE_ID [INT] NULL
	)


	-- Table variable to hold OBX records
	DECLARE @obx_data AS TABLE
	(		
		MESSAGE_ID [VARCHAR](50) NOT NULL,
		IDX [INT] NOT NULL,
		AccessionNumber VARCHAR(40) NOT NULL,
		OBR_OBJECT_ID [UNIQUEIDENTIFIER] NOT NULL,
		SET_ID [VARCHAR](20) NOT NULL,
		OBR_SET_ID [VARCHAR](20) NOT NULL,
		VALUE_TYPE [VARCHAR](10) NULL,
		TEST_ID [VARCHAR](20) NULL,
		TEST_NAME [VARCHAR](50) NULL,
		TEST_CODE VARCHAR(50) NULL,
		TEST_CODE_INDEX INT NULL,
		RESULT_DATA [VARCHAR](MAX) NULL,
		RESULT_VALUE VARCHAR(MAX) NULL,
		RESULT_CODE VARCHAR(MAX) NULL,
		RESULT_STATUS [VARCHAR](10) NULL,
		OBJECT_ID [UNIQUEIDENTIFIER] NOT NULL
	)


    -- Start a new transaction
BEGIN TRANSACTION trans1;

    -- Check for nulls in non-nullable columns
    IF @MessageId IS NULL
    BEGIN
        SELECT @error = -100;
        SELECT @errormsg = 'MessageId argument is null.';
        GOTO error;
    END;

    IF NOT EXISTS
    (
        SELECT MessageID
        FROM Orchard_ap_staging.dbo.AP_HL7Data
        WHERE MessageID = @MessageId
    )
    BEGIN
        SELECT @error = -100;
        SELECT @errormsg = 'MessageId not found in the AP_HL7Data table.';
        GOTO error;
    END;

    BEGIN TRY
            -- set local variables
        SELECT @hl7_message_text = HL7Message,
               @hl7_message_control_id = MsgControl
        FROM dbo.AP_HL7Data
        WHERE MessageID = @MessageId;

        SELECT @hl7_result_status = OBR_F25_C1,
               @hl7_observation_date_tm = dbo.f_format_hl7_date(OBR_F7_C1),
			   @accessionNumber = OBR_F3_C1
        FROM dbo.AP_Segment_OBR_A
        WHERE MessageID = @MessageId;

        SELECT @hl7_species = pid.PID_F10_C1,
               @patient_id = pid.PID_F2_C1
        FROM dbo.AP_Segment_PID_A AS pid
        WHERE pid.MessageID = @MessageId;

        -- get container id
        SELECT @container = EntityId
        FROM labkey.core.Containers AS c
        WHERE c.Name = 'SNPRC';

    END TRY
    BEGIN CATCH
        SELECT @error = -101;
        SELECT @errormsg = 'Error reading HL7 message data from staging database.';
        GOTO error;
    END CATCH;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- make sure we are working with an animal record
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SELECT @animal_id = d.ID
	FROM labkey.snprc_ehr.HL7_Demographics AS d
	WHERE d.ID = LTRIM(RTRIM(@patient_id))

	IF @animal_id IS NULL
	   GOTO not_animal_data;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Record change request - NOT ALLOWED AT THIS TIME
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	IF @hl7_result_status = 'C'
    BEGIN
		SET @error = -102
		SET @errormsg
        = 'CHANGE Record request: ' + @MessageId + CHAR(13) + CHAR(10) + 'NOT ALLOWED AT THIS TIME'
		GOTO error;
	END

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Record delete request
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    IF @hl7_result_status = 'X'
    BEGIN
        BEGIN TRY
			INSERT INTO labkey.snprc_ehr.HL7_DeletePathologyCasesStaging
			(
				AccessionNumber,
				ObjectId
			)
			(
				SELECT pcs.AccessionNumber,
						pcs.objectId
				FROM labkey.snprc_ehr.HL7_PathologyCasesStaging AS pcs
				WHERE pcs.accessionNumber = @accessionNumber
			)
		 END TRY
				BEGIN CATCH
					SELECT @error = -101;
					SELECT @errormsg
						= 'Record for deletion does not exist: *' + @accessionNumber + '* in HL7_PathologyCasesStaging.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
					GOTO error;
				END CATCH;

		BEGIN TRY
			INSERT INTO labkey.snprc_ehr.HL7_DeletePathologyDiagnosesStaging
			(
				AccessionNumber,
				ObjectId
			)
			(
				SELECT pds.AccessionNumber,
						pds.objectId
				FROM labkey.snprc_ehr.HL7_PathologyDiagnosesStaging AS pds
				WHERE pds.accessionNumber = @accessionNumber
			)
		 END TRY
         BEGIN CATCH
             SELECT @error = -101;
             SELECT @errormsg
                = 'Record for deletion does not exist: *' + @accessionNumber + '* in HL7_PathologyDiagnosesStaging.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
             GOTO error;
         END CATCH;

		GOTO finis
	END

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- New Record request
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    --------------------------------------------------------------------------------------------------------
    -- Populate table variable to hold OBR data
	BEGIN
        BEGIN TRY
          INSERT INTO @obr_data
            (
                MESSAGE_ID,
                IDX,
                MESSAGE_CONTROL_ID,
                ANIMAL_ID,
                VERIFIED_DATE_TM,
                REQUESTED_DATE_TM,
                OBSERVATION_DATE_TM,
                SPECIMEN_RECEIVED_DATE_TM,
                SET_ID,
                SPECIMEN_NUM,
                PROCEDURE_ID,
                PROCEDURE_NAME,
                PRIORITY,
                RESULT_STATUS,
                TECHNICIAN_LAST_NAME,
                TECHNICIAN_FIRST_NAME,
                CHARGE_ID,
                OBJECT_ID
            )
            SELECT obr.MessageID,
                    obr.IDX,
                    msh.MSH_F10_C1,
                    @animal_id,
                    dbo.f_format_hl7_date(obr.OBR_F22_C1), -- verified_date_tm
                    dbo.f_format_hl7_date(obr.OBR_F6_C1),  -- requested_date_tm
                    dbo.f_format_hl7_date(obr.OBR_F7_C1),  -- observation_date_tm
                    dbo.f_format_hl7_date(obr.OBR_F14_C1), -- specimen_received_date_tm
                    obr.OBR_F1_C1,                         -- Set_ID
                    obr.OBR_F3_C1,                         --Filler Order Number
                    obr.OBR_F4_C1,                         -- Procedure ID
                    obr.OBR_F4_C2,                         -- Procedure Name
                    obr.OBR_F5_C1,                         -- Priority
                    LTRIM(RTRIM(obr.OBR_F25_C1)),          -- Result status
                    obr.OBR_F34_C1,                        -- Technician last name
                    obr.OBR_F34_C2,                        -- Technician first name
                    pv1.PV1_F24_C1,                        --charge_id  -- TODO: maps to HL7 Contract Code
                    NEWID()								   -- object_ID

            FROM dbo.AP_Segment_OBR_A AS obr
            INNER JOIN dbo.AP_Segment_PID_A AS pid ON pid.MessageID = obr.MessageID
            INNER JOIN dbo.AP_Segment_MSH_A AS msh ON msh.MessageID = obr.MessageID
            INNER JOIN dbo.AP_Segment_PV1_A AS pv1 ON pv1.MessageID = obr.MessageID
            INNER JOIN dbo.AP_HL7Data AS h ON h.MessageID = obr.MessageID
            -- ignore rows that are currently being processed
            WHERE obr.MessageID = @MessageId AND LTRIM(RTRIM(obr.OBR_F25_C1)) = 'F';
        END TRY
        BEGIN CATCH
            SELECT @error = -101;
            SELECT @errormsg
                = 'Error inserting message: *' + @MessageId + '* into @obr_data.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
            GOTO error;
        END CATCH;

        -- Populate the obx table variable
        BEGIN TRY
                -- This is a little tricky. The OBR and OBX records match on MessageId; however multiple OBR records can be in a single message.
                -- If that happens, the IDX value of the OBX records that match a given OBR record will be one greater than the OBR's IDX value,
                -- and will increment to be one less than the next OBR's IDX value. The LEAD function is used to get the next OBR.IDX value and
                -- the OBX records are constrained by the OBR.IDX and OBR.next_OBR_IDX. A CTE is used to select the OBR records.
                ;
                WITH cte
                AS (SELECT OBR.MessageID,
                           OBR.IDX AS OBR_IDX,
                           OBR.OBR_F3_C1 AS AccessionNumber,
                           OBR.OBR_F1_C1 AS SET_ID,
                           OBR.OBR_F25_C1 AS RESULT_STATUS,
                           cbr.OBJECT_ID AS obr_object_id,
                           OBR.OBR_F4_C1 AS obr_service_id,
                           LEAD(OBR.IDX, 1, 9999) OVER (ORDER BY OBR.IDX) AS next_OBR_IDX
                    FROM  [dbo].[AP_Segment_OBR_A] AS obr
                    INNER JOIN @obr_data AS cbr ON obr.MessageID = cbr.MESSAGE_ID AND obr.OBR_F1_C1 = cbr.SET_ID
                    WHERE obr.MessageID = @MessageId)


                INSERT INTO @obx_data
                (
                    MESSAGE_ID,
                    IDX,
                    AccessionNumber,
                    OBR_OBJECT_ID,
                    SET_ID,
                    OBR_SET_ID,
                    VALUE_TYPE,
                    TEST_ID,
                    TEST_NAME,
                    TEST_CODE,
                    TEST_CODE_INDEX,
                    RESULT_DATA,
                    RESULT_VALUE,
                    RESULT_CODE,
                    RESULT_STATUS,
                    OBJECT_ID
                )
                SELECT obx.MessageID,
                       obx.IDX,
                       cte.AccessionNumber,
                       cte.obr_object_id,
                       obx.OBX_F1_C1,
                       cte.SET_ID, -- OBR SET ID
                       obx.OBX_F2_C1,
                       obx.OBX_F3_C1,
                       obx.OBX_F3_C2,
                       CASE WHEN obx.OBX_F3_C1 LIKE 'CODEMORPH%' THEN 'CODEMORPH'
                            WHEN obx.OBX_F3_C1 LIKE 'CODEORGAN%' THEN 'CODEORGAN'
                            WHEN obx.OBX_F3_C1 LIKE 'CODESPETIOLOGY%' THEN 'CODESPETIOLOGY'
                            WHEN obx.OBX_F3_C1 LIKE 'CODEETIOLOGY%' THEN 'CODEETIOLOGY'
                            ELSE NULL END AS TEST_CODE,
                      CASE WHEN obx.OBX_F3_C1 LIKE 'CODEMORPH%' THEN RIGHT(obx.OBX_F3_C1, LEN(obx.OBX_F3_C1) - 9)
                           WHEN obx.OBX_F3_C1 LIKE 'CODEORGAN%' THEN RIGHT(obx.OBX_F3_C1, LEN(obx.OBX_F3_C1) - 9)
                           WHEN obx.OBX_F3_C1 LIKE 'CODESPETIOLOGY%' THEN RIGHT(obx.OBX_F3_C1, LEN(obx.OBX_F3_C1) - 14)
                           WHEN obx.OBX_F3_C1 LIKE 'CODEETIOLOGY%' THEN RIGHT(obx.OBX_F3_C1, LEN(obx.OBX_F3_C1) - 12)
                           ELSE NULL END  AS TEST_CODE_INDEX,

                       obx.OBX_RESULTDATA,
                       [dbo].[f_split] (obx.OBX_RESULTDATA, ';', 1) AS RESULT_VALUE,
                       [dbo].[f_split] (obx.OBX_RESULTDATA, ';', 2) AS RESULT_CODE,

                       obx.OBX_F6_C1,
                    NEWID()
                FROM dbo.AP_Segment_OBX_A AS obx
                INNER JOIN cte ON obx.MessageID = cte.MessageID
                           AND obx.IDX > cte.OBR_IDX
                           AND obx.IDX < cte.next_OBR_IDX
                               -- only load data with result_status = 'F' (final).
                           AND cte.RESULT_STATUS = 'F'
                WHERE obx.OBX_F3_C1 IS NULL OR RTRIM(LTRIM(obx.OBX_F3_C1)) <> 'PDFReport'

            END TRY
            BEGIN CATCH
                SELECT @error = -101;
                SELECT @errormsg
                    = 'Error inserting message: *' + @MessageId + '* into @obx_data.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
                GOTO error;
            END CATCH;

    -- insert into the HL7_PathologyCasesStaging table

        BEGIN
            BEGIN TRY
                INSERT INTO labkey.snprc_ehr.HL7_PathologyCasesStaging
                (
                    ID,
                    Date,
                    AccessionNumber,
                    AccessionCode,
                    Tissue,
                    PerformedBy,
                    Description,
                    Remark,
                    ObjectId,
                    ApathRecordStatus,
                    DeathType,
                    Created,
                    CreatedBy,
                    Modified,
                    ModifiedBy,
                    Container
                )

                ( SELECT
                    obr.ANIMAL_ID AS ID,
                    obr.OBSERVATION_DATE_TM AS Date,
                    obr.SPECIMEN_NUM AS AccessionNumber,
                    IIF(obr.PROCEDURE_ID = 'NECROPSY', 'N', 'S') AS AccessionCode,
                    (SELECT TOP (1) obx.RESULT_VALUE
                        FROM @obx_data AS obx
                        WHERE obx.TEST_NAME = 'Tissue' AND obx.OBR_OBJECT_ID = obr.object_id
                    ) AS Tissue,
                    obr.TECHNICIAN_FIRST_NAME + ' ' + obr.TECHNICIAN_LAST_NAME as performedBy,
                    NULL as Description,
                    (SELECT TOP (1) obx.RESULT_DATA
                        FROM @obx_data AS obx
                        WHERE obx.TEST_NAME = 'SIGNATURE' AND obx.OBR_OBJECT_ID = obr.object_id
                    ) AS Remark,
                    obr.OBJECT_ID AS ObjectId,
                    CASE WHEN obr.RESULT_STATUS = 'F' THEN 'C' -- "Completed"
                        WHEN obr.RESULT_STATUS = 'C' THEN 'C' -- 'Correction"
                        WHEN obr.RESULT_STATUS = 'P' THEN 'F' -- 'Preliminary"
                    ELSE NULL END AS ApathRecordStatus,

                    (SELECT
                        CASE WHEN SUBSTRING(LTRIM(obx.RESULT_VALUE), 1, 5) = 'Eutha' THEN 'E'
                            WHEN SUBSTRING(LTRIM(obx.RESULT_VALUE), 1, 5) = 'Found' THEN 'N'
                            WHEN SUBSTRING(LTRIM(obx.RESULT_VALUE), 1, 5) = 'Resea' THEN 'R'
                            WHEN SUBSTRING(LTRIM(obx.RESULT_VALUE), 1, 5) = 'Sacri' THEN 'S'
                            ELSE 'U'
                            END
                        FROM @obx_data AS obx
                        WHERE obx.TEST_NAME = 'TYPE OF DEATH' AND obx.OBR_OBJECT_ID = obr.object_id
                    ) AS DeathType,

                    GETDATE() AS Created,
                    u.UserId AS CreatedBy,
                    GETDATE() AS Modified,
                    u.UserId AS ModifiedBy,
                    @container
                    FROM @obr_data AS obr
                    INNER JOIN labkey.core.Principals AS u ON u.Name LIKE 'hl7_Admin%'
                )

            END TRY
            BEGIN CATCH
                SET @error = -101
                SET @errormsg
                = 'Error inserting message: *' + @MessageId + '* into HL7_PathologyCasesStaging.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
                GOTO error;
            END CATCH;

        -- process OBX records for PathologyDiagnosesStaging
            SET @ctr = 1


            SET @msgCursor = CURSOR LOCAL FOR
                SELECT obr.OBJECT_ID
                FROM @obr_data AS obr

                FOR READ ONLY

                OPEN @msgCursor
                FETCH @msgCursor INTO @obr_object_id

                WHILE (@@FETCH_STATUS = 0)
                BEGIN

                    SET @maxRecords = (SELECT MAX(obx.TEST_CODE_INDEX) FROM @obx_data AS obx WHERE obx.OBR_OBJECT_ID = @obr_object_id)
                    WHILE (@ctr <= @maxRecords)
                    BEGIN
                        BEGIN TRY
                            INSERT INTO labkey.snprc_ehr.HL7_PathologyDiagnosesStaging
                            (
                                ID,
                                Date,
                                AccessionNumber,
                                Morphology,
                                Organ,
                                EtiologyCode,
                                SpecificEtiology,
                                PerformedBy,
                                Remark,
                                Description,
                                ObjectId,
                                Created,
                                CreatedBy,
                                Modified,
                                ModifiedBy,
                                Container
                            )
                            (
                            SELECT obr.ANIMAL_ID AS ID,
                                   obr.OBSERVATION_DATE_TM AS Date,
                                   obr.SPECIMEN_NUM AS AccessionNumber,
                                (SELECT TOP(1) obx.RESULT_VALUE
                                    FROM @obx_data AS obx
                                    WHERE obr.OBJECT_ID = obx.OBR_OBJECT_ID AND
                                    obx.TEST_CODE =  'CODEMORPH' AND obx.TEST_CODE_INDEX = @ctr
                                ) AS Morphology,
                                (SELECT TOP (1) obx.RESULT_VALUE
                                    FROM @obx_data AS obx
                                    WHERE obr.OBJECT_ID = obx.OBR_OBJECT_ID AND
                                    obx.TEST_CODE =  'CODEORGAN' AND obx.TEST_CODE_INDEX = @ctr
                                ) AS Organ,
                                (SELECT TOP (1) obx.RESULT_CODE
                                    FROM @obx_data AS obx
                                    WHERE obr.OBJECT_ID = obx.OBR_OBJECT_ID AND
                                    obx.TEST_CODE =  'CODEETIOLOGY' AND obx.TEST_CODE_INDEX = @ctr
                                ) AS Etiology,
                                (SELECT TOP (1) obx.RESULT_VALUE
                                    FROM @obx_data AS obx
                                    WHERE obr.OBJECT_ID = obx.OBR_OBJECT_ID AND
                                    obx.TEST_CODE =  'CODESPETIOLOGY' AND obx.TEST_CODE_INDEX = @ctr
                                ) AS SpecificEtiology,
                                obr.TECHNICIAN_FIRST_NAME + ' ' + obr.TECHNICIAN_LAST_NAME as performedBy,
                                NULL AS Remark,
                                NULL AS Description,
                                NEWID() AS ObjectId,
                                GETDATE() AS Created,
                                u.UserId AS CreatedBy,
                                GETDATE() AS Modified,
                                u.UserId AS ModifiedBy,
                                @container

                            FROM @obr_data AS obr
                            INNER JOIN labkey.core.Principals AS u ON u.Name LIKE 'hl7_Admin%'

                        )
                    END TRY
                    BEGIN CATCH
                        select @error = @@ERROR
                        SELECT @errormsg = 'Error inserting message: *' + @messageid + 'into HL7_PathologyDiagnosesStaging ' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                        goto error
                    END CATCH

                    SET @ctr = @ctr + 1
                END
                FETCH NEXT FROM @msgCursor INTO @obr_object_id
            END
            CLOSE @msgCursor
            DEALLOCATE @msgCursor

            -- update local import log
            INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG
            (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
            VALUES (@MessageId, @hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'AP upload okay.', @container);

            -- Jump over error handling
            GOTO finis;
        END
    END


error:
    -- an error occurred, rollback the entire transaction.
    ROLLBACK TRANSACTION trans1;

    INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG
    ( MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container )
    VALUES
        (@MessageId, @hl7_observation_date_tm, @hl7_message_control_id, @error, @hl7_result_status, @animal_id,
         @hl7_species, @hl7_message_text, @errormsg, @container);

    UPDATE Orchard_ap_staging.dbo.AP_HL7Data
    SET Processed = 1,
        StatusMessage = 'ERROR: Processed By p_load_ap_data.sql'
    WHERE MessageID = @MessageId;
	SELECT @errormsg
    RETURN @error;

not_animal_data:


	INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
	VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, 2, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'Not animal data.', @container)

	GOTO finis

-- If no error occurred, commit the entire transaction.
finis:
	-- Used only during testing
	--SELECT * FROM @obr_data
	--SELECT * FROM @obx_data
	--SELECT * FROM labkey.snprc_ehr.HL7_PathologyCasesStaging
	--SELECT * FROM labkey.snprc_ehr.HL7_PathologyDiagnosesStaging

	-- update HermeTech table
    UPDATE Orchard_ap_staging.dbo.AP_HL7Data
    SET Processed = 1,
        StatusMessage = 'SUCCESS: Processed By p_load_ap_data.sql'
    WHERE MessageID = @MessageId;

	COMMIT TRANSACTION trans1;

    RETURN 0;

    SET NOCOUNT OFF

END

GO


--GRANT EXEC ON p_load_ap_data TO hl7_admin;

--USE labkey
--GRANT SELECT ON labkey.core.Containers TO hl7_admin;
--GRANT SELECT ON labkey.core.Principals TO hl7_admin;


--GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyDiagnosesStaging TO hl7_admin;
--GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyCasesStaging TO hl7_admin;
--GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_PathologyDiagnosesStaging TO hl7_admin;
--GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyCasesStaging  TO hl7_admin;
--GRANT SELECT ON labkey.snprc_ehr.HL7_Demographics TO hl7_admin;
--USE Orchard_AP_staging

GO