USE [Orchard_HL7_staging]
GO
/****** Object:  StoredProcedure [dbo].[p_load_hl7_data]    Script Date: 1/10/2023 2:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:		Terry Hawkins
-- Create date: 05/19/2022
-- Description:	loads HL7 results from Orchard Harvest
-- Returns:
--     0             Okay
--   -1 thru -99     Reserved by sql server for system errors
--    -100           Illegal null value passed into procedure
--    -101           General error
--    -102           Illegal update column passed into procedure
--    @@error        SQL errors
--
-- Note: hl7_import_log import_status:
--	1 == import okay
--  2 == animal not found in master table or as a cage location
--  3 == preliminary data - not uploaded
-- other == SQL server error number
--
-- Changes:
-- NOTE: Replaces p_load_hl7_data.sql - 1/31/2023 Terry
-- =================================================================
DROP PROCEDURE IF EXISTS [dbo].[p_load_hl7_data]
GO

CREATE PROCEDURE [dbo].[p_load_hl7_data](@MessageId VARCHAR(50))
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE
        @error INTEGER,
        @errormsg VARCHAR(MAX),
		@successmsg VARCHAR(MAX),
        @animal_id VARCHAR(7),
        @hl7_message_text VARCHAR(MAX),
        @hl7_message_control_id VARCHAR(50),
        @hl7_result_status VARCHAR(10),
        @hl7_species VARCHAR(50),
        @hl7_observation_date_tm DATETIME,
        @patient_id VARCHAR(32),
        @container UNIQUEIDENTIFIER,
		@msgCursor CURSOR,
		@obr_set_id INTEGER,
		@obr_object_id UNIQUEIDENTIFIER,
		@obr_message_id VARCHAR(50),
        @isPreliminary INTEGER,
        @ctr INTEGER

	DECLARE @ObjectId_TableVar TABLE (ObjectId UNIQUEIDENTIFIER );

    SET @animal_id = NULL
    SET @hl7_message_text = 'Could not read message text.';
    SET @hl7_message_control_id = 'Unprocessed.';
    SET @hl7_result_status = 'Error';
    SET @hl7_species = 'Unprocessed';
    SET @hl7_observation_date_tm = '01-01-1900 00:00'
    SET @isPreliminary = 0
    SET @ctr = 0

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
            FROM Orchard_hl7_staging.dbo.ORC_HL7Data
            WHERE MessageID = @MessageId
        )
        BEGIN
            SELECT @error = -100;
            SELECT @errormsg = 'MessageId not found in the ORC_HL7Data table.';
            GOTO error;
        END;

    BEGIN TRY
        -- set local variables
        SELECT @hl7_message_text = HL7Message,
               @hl7_message_control_id = MsgControl,
               @hl7_observation_date_tm = DateLoaded
        FROM dbo.ORC_HL7Data
        WHERE MessageID = @MessageId;


-- Get patient information
        SELECT @hl7_species = pid.PID_F10_C1,
               @patient_id = pid.PID_F2_C1
        FROM dbo.ORC_Segment_PID_A AS pid
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

    --------------------------------------------------------------------------------------------------------
-- insert into MSH table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_MSH
        (MESSAGE_ID,
         IDX,
         SENDING_APPLICATION,
         SENDING_FACILITY,
         RECEIVING_APPLICATION,
         RECEIVING_FACILITY,
         MESSAGE_TYPE,
         TRIGGER_EVENT_ID,
         MESSAGE_CONTROL_ID,
         MESSAGE_DATE_TM,
         Container)
        SELECT msh.MessageID,
               msh.IDX,
               msh.MSH_F3_C1,
               msh.MSH_F4_C1,
               msh.MSH_F5_C1,
               msh.MSH_F5_C1,
               msh.MSH_F9_C1,
               msh.MSH_F9_C2,
               msh.MSH_F10_C1,
               dbo.f_format_hl7_date(msh.MSH_F7_C1),
               @container AS Container
        FROM Orchard_hl7_staging.dbo.ORC_Segment_MSH_A AS msh
        WHERE msh.MessageID = @MessageId;
    END TRY
    BEGIN CATCH
        SELECT @error = -101;
        SELECT @errormsg
                   =
               'Error inserting message: *' + @MessageId + '* into HL7_MSH.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
        GOTO error;
    END CATCH;
    --------------------------------------------------------------------------------------------------------
    -- insert into PID table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_PID
        (MESSAGE_ID,
         IDX,
         SET_ID,
         PATIENT_ID_EXTERNAL,
         PATIENT_ID_INTERNAL,
         BIRTHDATE,
         SEX,
         BREED,
         SPECIES,
         ACCOUNT_NUMBER,
         DEATH_DATE,
         Container)
            (SELECT pid.MessageID,                        -- MESSAGE_ID - varchar(50)
                    pid.IDX,                              -- IDX - int
                    pid.PID_F1_C1,                        -- SET_ID - varchar(20)
                    pid.PID_F2_C1,                        -- PATIENT_ID_EXTERNAL - varchar(20)
                    pid.PID_F3_C1,                        -- PATIENT_ID_INTERNAL - varchar(20)
                    dbo.f_format_hl7_date(pid.PID_F7_C1), -- BIRTHDATE - datetime
                    pid.PID_F8_C1,                        -- SEX - varchar(20)
                    pid.PID_F10_C1,                       -- BREED - varchar(50)
                    pid.PID_F22_C1,                       -- SPECIES - varchar(50)
                    pid.PID_F18_C1,                       -- ACCOUNT_NUMBER - varchar(50)
                    dbo.f_format_hl7_date(pid.PID_F29_C1),
                    @container                            -- Container
             FROM Orchard_hl7_staging.dbo.ORC_Segment_PID_A AS pid
             WHERE pid.MessageID = @MessageId);
    END TRY
    BEGIN CATCH
        SELECT @error = -101;
        SELECT @errormsg
                   =
               'Error inserting message: *' + @MessageId + '* into HL7_PID.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
        GOTO error;
    END CATCH;
    --------------------------------------------------------------------------------------------------------

    -- insert into PV1 table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_PV1
        (MESSAGE_ID,
         IDX,
         SET_ID,
         ADMISSION_TYPE,
         ATTENDING_DOCTOR_LAST,
         ATTENDING_DOCTOR_FIRST,
         VISIT_NUMBER,
         CHARGE_NUMBER,
         ADMIT_DATE,
         Container)
            (SELECT pv1.MessageID,                          -- MESSAGE_ID - varchar(50)
                    pv1.IDX,                                -- IDX - int
                    pv1.PV1_F1_C1,                          -- SET_ID - varchar(20)
                    pv1.PV1_F4_C1,                          -- ADMISSION_TYPE - varchar(20)
                    pv1.PV1_F7_C2,                          -- ATTENDING_DOCTOR_LAST - varchar(50)
                    pv1.PV1_F7_C3,                          -- ATTENDING_DOCTOR_FIRST - varchar(50)
                    pv1.PV1_F19_C1,                         -- VISIT_NUMBER - varchar(20)
                    pv1.PV1_F22_C1,                         -- CHARGE_NUMBER - varchar(20)
                    dbo.f_format_hl7_date(pv1b.PV1_F44_C1), -- ADMIT_DATE
                    @container                              -- Container
             FROM Orchard_hl7_staging.dbo.ORC_Segment_PV1_A AS pv1
                      LEFT OUTER JOIN Orchard_hl7_staging.dbo.ORC_Segment_PV1_B AS pv1b
                                 ON pv1b.MessageID = pv1.MessageID
                                     AND pv1b.IDX = pv1.IDX
             WHERE pv1.MessageID = @MessageId);
    END TRY
    BEGIN CATCH
        SELECT @error = -101;
        SELECT @errormsg
                   =
               'Error inserting message: *' + @MessageId + '* into HL7_PV1.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
        GOTO error;
    END CATCH;

    --------------------------------------------------------------------------------------------------------
    -- insert into ORC table
    -- can have multiple ORC segments - let's get them all
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_ORC
        (MESSAGE_ID,
         IDX,
         ORDER_CONTROL_CODE,
         FILLER_ORDER_NUMBER,
         ENTERED_BY_LAST,
         ENTERED_BY_FIRST,
         VERIFIED_BY_LAST,
         VERIFIED_BY_FIRST,
         ORDER_PROVIDER_LAST,
         ORDER_PROVIDER_FIRST,
         CALLBACK_EMAIL,
         ORDER_DATE,
         Container)
            (SELECT orc.MessageID,                         -- MESSAGE_ID - varchar(50)
                    orc.IDX,                               -- IDX - int
                    orc.ORC_F1_C1,                         -- ORDER_CONTROL_CODE - varchar(20)
                    orc.ORC_F3_C1,                         -- FILLER_ORDER_NUMBER - varchar(22)
                    orc.ORC_F10_C2,                        -- ENTERED_BY_LAST - varchar(50)
                    orc.ORC_F10_C3,                        -- ENTERED_BY_FIRST - varchar(50)
                    orc.ORC_F11_C2,                        -- VERIFIED_BY_LAST - varchar(50)
                    orc.ORC_F11_C3,                        -- VERIFIED_BY_FIRST - varchar(50)
                    orc.ORC_F12_C2,                        -- ORDER_PROVIDER_LAST - varchar(50)
                    orc.ORC_F12_C3,                        -- ORDER_PROVIDER_FIRST - varchar(50)
                    orc.ORC_F14_C3,                        -- CALLBACK_EMAIL - varchar(50)
                    dbo.f_format_hl7_date(orc.ORC_F15_C1), -- ORDER_DATE - datetime
                    @container                             -- Container

             FROM Orchard_hl7_staging.dbo.ORC_Segment_ORC_A AS orc
             WHERE orc.MessageID = @MessageId);
    END TRY
    BEGIN CATCH
        SELECT @error = -101;
        SELECT @errormsg
                   =
               'Error inserting message: *' + @MessageId + '* into HL7_ORC.' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
        GOTO error;
    END CATCH;



	SET @msgCursor = CURSOR LOCAL FOR
		SELECT LTRIM(RTRIM(obr.OBR_F25_C1)), obr.OBR_F1_C1 -- @hl7_result_status, @obr_set_id
		FROM Orchard_HL7_staging.dbo.ORC_Segment_OBR_A AS obr
		WHERE obr.MessageID = @MessageId
		
		FOR READ ONLY

		OPEN @msgCursor
		FETCH @msgCursor INTO @hl7_result_status, @obr_set_id

    WHILE (@@FETCH_STATUS = 0)
    BEGIN

        IF @hl7_result_status = 'P'
        BEGIN
            SET @isPreliminary = 1
        END
        -- This section removes cancelled orders from the LabKey DB tables
        -- OBR result status = 'X' Order cancelled
        IF @hl7_result_status = 'X'
        BEGIN
                SET @isPreliminary = 0
                -- Get OBR ObjectId for matching observations and notes
                SELECT @obr_object_id = cbr.OBJECT_ID, @obr_message_id = cbr.MESSAGE_ID
                FROM labkey.snprc_ehr.HL7_OBR AS cbr
                INNER JOIN Orchard_HL7_staging.dbo.ORC_Segment_OBR_A AS OBR ON cbr.SPECIMEN_NUM = obr.OBR_F3_C1 AND cbr.PROCEDURE_ID = obr.OBR_F4_C1
                WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X' -- Result_status = Order cancelled
                      AND  obr.OBR_F1_C1 = @obr_set_id

                BEGIN TRY
                    -- remove observations
                    DELETE
                    FROM labkey.snprc_ehr.HL7_OBX
                    WHERE OBR_OBJECT_ID = @obr_object_id
                END TRY
                BEGIN CATCH
                    SELECT @error = -101;
                    SELECT @errormsg
                               = 'Error deleting message: *' + @MessageId + '* from HL7_OBX.' + CHAR(13) + CHAR(10) +
                                 ERROR_MESSAGE();
                    GOTO error;
                END CATCH;

                -- remove notes
                BEGIN TRY
                    DELETE
                    FROM labkey.snprc_ehr.HL7_NTE
                    WHERE OBR_OBJECT_ID = @obr_object_id
                END TRY
                BEGIN CATCH
                    SELECT @error = -101;
                    SELECT @errormsg
                               = 'Error deleting message: *' + @MessageId + '* from HL7_NTE.' + CHAR(13) + CHAR(10) +
                                 ERROR_MESSAGE();
                    GOTO error;
                END CATCH;

                -- delete observation request
                BEGIN TRY
                    DELETE
                    FROM labkey.snprc_ehr.HL7_OBR
                    WHERE OBJECT_ID = @obr_object_id
                END TRY
                BEGIN CATCH
                    SELECT @error = -101;
                    SELECT @errormsg
                               = 'Error deleting message: *' + @MessageId + '* from HL7_OBR.' + CHAR(13) + CHAR(10) +
                                 ERROR_MESSAGE();
                    GOTO error;
                END CATCH;

                -- if this is the last obr for the messageId, then clean up pv1, pid, orc, and msh tables
                IF NOT EXISTS (SELECT 1 FROM labkey.snprc_ehr.HL7_OBR AS cbr WHERE cbr.MESSAGE_ID = @obr_message_id)
                BEGIN

                    -- remove PV1
                    BEGIN TRY
                        DELETE
                        FROM labkey.snprc_ehr.HL7_PV1
                        WHERE MESSAGE_ID IN (@obr_message_id, @MessageId)
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                   = 'Error deleting message: *' + @MessageId + '* from HL7_PV1.' + CHAR(13) + CHAR(10) +
                                     ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                    -- remove pid
                    BEGIN TRY
                        DELETE
                        FROM labkey.snprc_ehr.HL7_PID
                        WHERE MESSAGE_ID IN (@obr_message_id, @MessageId)
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                   = 'Error deleting message: *' + @MessageId + '* from HL7_PID.' + CHAR(13) + CHAR(10) +
                                     ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                -- remove ORC
                    BEGIN TRY
                        DELETE
                        FROM labkey.snprc_ehr.HL7_ORC
                        WHERE MESSAGE_ID IN (@obr_message_id, @MessageId)
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                   = 'Error deleting message: *' + @MessageId + '* from ORC.' + CHAR(13) + CHAR(10) +
                                     ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                -- remove MSH
                    BEGIN TRY
                        DELETE
                        FROM labkey.snprc_ehr.HL7_MSH
                        WHERE MESSAGE_ID IN (@obr_message_id, @MessageId)
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                   = 'Error deleting message: *' + @MessageId + '* from MSH.' + CHAR(13) + CHAR(10) +
                                     ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                END
            END;

            -- Process messeges for new results, changed result, and deleted tests
            --
            IF @hl7_result_status IN ( 'F', 'C', 'D')
            BEGIN
                SET @isPreliminary = 0
                -- RESULT_STATUS = 'F', 'C', 'D' - Add the OBR record
                BEGIN TRY
                    INSERT INTO labkey.snprc_ehr.HL7_OBR
                    (MESSAGE_ID,
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
                        OBJECT_ID,
                        Container)
                    OUTPUT Inserted.OBJECT_ID INTO  @ObjectId_TableVar
                    SELECT obr.MessageID,
                            obr.IDX,
                            msh.MSH_F10_C1,
                            @animal_id,
                            dbo.f_format_hl7_date(obr.OBR_F22_C1), -- verified_date_tm
                            dbo.f_format_hl7_date(obr.OBR_F6_C1),  -- requested_date_tm
                            -- Increment the time by one second per OBR to ensure they
                            -- sort correctly when displaying results
                            DATEADD(SECOND, @ctr, dbo.f_format_hl7_date(obr.OBR_F7_C1)),  -- observation_date_tm
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
                            NEWID(),                               -- object_ID
                            @container
                    FROM dbo.ORC_Segment_OBR_A AS obr
                                JOIN dbo.ORC_Segment_PID_A AS pid
                                    ON pid.MessageID = obr.MessageID
                                JOIN dbo.ORC_Segment_MSH_A AS msh
                                    ON msh.MessageID = obr.MessageID
                                JOIN dbo.ORC_Segment_PV1_A AS pv1
                                    ON pv1.MessageID = obr.MessageID
                                JOIN dbo.ORC_HL7Data AS h
                                    ON h.MessageID = obr.MessageID
                            -- ignore rows that are currently being processed
                    WHERE obr.MessageID = @MessageId
                        AND LTRIM(RTRIM(obr.OBR_F25_C1)) IN ( 'F', 'C', 'D')
                        AND  obr.OBR_F1_C1 = @obr_set_id
                END TRY
                BEGIN CATCH
                    SELECT @error = -101;
                    SELECT @errormsg
                                = 'Error inserting message: *' + @MessageId + '* into HL7_OBR.' + CHAR(13) + CHAR(10) +
                                    ERROR_MESSAGE();
                    GOTO error;
                END CATCH;


                -- get OBR's ObjectId
                SELECT TOP (1) @obr_object_id = objectId FROM @ObjectId_TableVar ORDER BY ObjectId

                IF @hl7_result_status IN ( 'F')
                SET @isPreliminary = 0
                BEGIN
                    BEGIN TRY
                        -- This is a little tricky. The OBR and OBX records match on MessageId; however multiple OBR records can be in a single message.
                        -- If that happens, the IDX value of the OBX records that match a given OBR record will be one greater than the OBR's IDX value,
                        -- and will increment to be one less than the next OBR's IDX value. The LEAD function is used to get the next OBR.IDX value and
                        -- the OBX records are constrained by the OBR.IDX and OBR.next_OBR_IDX. A CTE is used to select the OBR records.

                    -- New OBX records - Result Status F

                        ;WITH cte AS (
                            SELECT a.MessageID,
                                a.OBR_IDX,
                                a.SET_ID,
                                a.RESULT_STATUS,
                                cbr.object_id AS obr_object_id,
                                a.obr_service_id,
                                a.next_OBR_IDX
                                FROM
                                (
                                    SELECT OBR.MessageID,
                                        OBR.IDX                                        AS OBR_IDX,
                                        OBR.OBR_F1_C1                                  AS SET_ID,
                                        OBR.OBR_F25_C1                                 AS RESULT_STATUS,
                                        OBR.OBR_F4_C1                                  AS obr_service_id,
                                        LEAD(OBR.IDX, 1, 9999) OVER (ORDER BY OBR.IDX) AS next_OBR_IDX
                                    FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
                                    WHERE OBR.MessageID = @MessageId
                                ) a
                            INNER JOIN labkey.snprc_ehr.HL7_OBR AS cbr
                                        ON a.MessageID = cbr.MESSAGE_ID  AND cbr.SET_ID =a.SET_ID
                            WHERE a.MessageID = @MessageId AND a.SET_ID = @obr_set_id
                        )


                        INSERT INTO labkey.snprc_ehr.HL7_OBX
                        (MESSAGE_ID,
                            IDX,
                            OBR_OBJECT_ID,
                            SET_ID,
                            OBR_SET_ID,
                            VALUE_TYPE,
                            TEST_ID,
                            TEST_NAME,
                            serviceTestId,
                            QUALITATIVE_RESULT,
                            RESULT,
                            UNITS,
                            REFERENCE_RANGE,
                            ABNORMAL_FLAGS,
                            RESULT_STATUS,
                            Container)
                        SELECT obx.MessageID,
                                obx.IDX,
                                cte.obr_object_id,
                                obx.OBX_F1_C1,
                                cte.SET_ID, -- OBR SET ID
                                obx.OBX_F2_C1,
                                obx.OBX_F3_C1,
                                obx.OBX_F3_C2,
                                lp.ObjectId,
                                obx.OBX_RESULTDATA,
                                CASE
                                    WHEN obx.OBX_F2_C1 = 'NM'
                                        AND labkey.snprc_ehr.f_isNumeric(obx.OBX_RESULTDATA) = 1 THEN
                                        CAST(LTRIM(RTRIM(REPLACE(obx.OBX_RESULTDATA, ' ', ''))) AS DECIMAL(10, 3))
                                    ELSE
                                        NULL
                                    END      AS RESULT,
                                REPLACE(REPLACE(REPLACE(REPLACE(obx.OBX_F6_C1, '\T\', '&'), '\S\', '^'), '\F\', '|'), '\R\',
                                        '~') AS UNITS,
                                obx.OBX_F7_C1,
                                obx.OBX_F8_C1,
                                obx.OBX_F11_C1,
                                @container
                        FROM dbo.ORC_Segment_OBX_A AS obx
                                    INNER JOIN cte
                                            ON obx.MessageID = cte.MessageID
                                                AND obx.IDX > cte.OBR_IDX
                                                AND obx.IDX < cte.next_OBR_IDX
                                                AND  cte.set_id = @obr_set_id
                                    LEFT OUTER JOIN labkey.snprc_ehr.labwork_panels AS lp
                                                    ON cte.obr_service_id = lp.ServiceId
                                                        AND obx.OBX_F3_C1 = lp.TestId

                                                        -- only load data with result_status = 'F' (final).
                                                        AND cte.RESULT_STATUS = 'F';
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                    = 'Error inserting message: *' + @MessageId + '* into HL7_OBX.' + CHAR(13) + CHAR(10) +
                                        ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                    -- New NTE records
                    BEGIN TRY
                        ;WITH cte AS (
                            SELECT a.MessageID,
                                a.OBR_IDX,
                                a.SET_ID,
                                a.RESULT_STATUS,
                                cbr.object_id AS obr_object_id,
                                a.obr_service_id,
                                a.next_OBR_IDX
                                FROM
                                (
                                    SELECT OBR.MessageID,
                                        OBR.IDX                                        AS OBR_IDX,
                                        OBR.OBR_F1_C1                                  AS SET_ID,
                                        OBR.OBR_F25_C1                                 AS RESULT_STATUS,
                                        OBR.OBR_F4_C1                                  AS obr_service_id,
                                        LEAD(OBR.IDX, 1, 9999) OVER (ORDER BY OBR.IDX) AS next_OBR_IDX
                                    FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
                                    WHERE OBR.MessageID = @MessageId
                                ) a
                            INNER JOIN labkey.snprc_ehr.HL7_OBR AS cbr
                                        ON a.MessageID = cbr.MESSAGE_ID  AND cbr.SET_ID = a.SET_ID
                            WHERE a.MessageID = @MessageId AND a.SET_ID = @obr_set_id
                        )
                        INSERT INTO labkey.snprc_ehr.HL7_NTE
                        (MESSAGE_ID,
                            IDX,
                            OBR_OBJECT_ID,
                            SET_ID,
                            OBR_SET_ID,
                            COMMENT,
                            Container)
                        SELECT nte.MessageID,
                                nte.IDX,
                                cte.obr_object_id,
                                nte.NTE_F1_C1,
                                cte.SET_ID, -- OBR_SET_ID
                                nte.NTE_F3_C1,
                                @container
                        FROM Orchard_hl7_staging.dbo.ORC_Segment_NTE_A AS nte
                                    INNER JOIN cte
                                            ON nte.MessageID = cte.MessageID
                                                AND nte.IDX > cte.OBR_IDX
                                                AND nte.IDX < cte.next_OBR_IDX
                                                AND cte.SET_ID = @obr_set_id
                                                -- only load data with result_status = 'F' (final).
                                                AND cte.RESULT_STATUS = 'F';
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                    = 'Error inserting message: *' + @MessageId + '* into HL7_OBR.' + CHAR(13) + CHAR(10) +
                                        ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;
                END
                -- Process messeges for corrected results
                -- RESULT_STATUS = 'C' for corrected entries, 'D' for deleted entries
                -- OBR entries don't change
                IF @hl7_result_status IN ( 'C','D')
                BEGIN
                    SET @isPreliminary = 0
                    -- Get OBR ObjectId for matching observations and notes
                    SELECT @obr_object_id = cbr.OBJECT_ID, @obr_message_id = cbr.MESSAGE_ID
                    FROM labkey.snprc_ehr.HL7_OBR AS cbr
                    INNER JOIN Orchard_HL7_staging.dbo.ORC_Segment_OBR_A AS OBR ON cbr.SPECIMEN_NUM = obr.OBR_F3_C1 AND cbr.PROCEDURE_ID = obr.OBR_F4_C1
                    WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) IN ('C', 'D') -- Result_status = Results changed or deleted
                          AND  obr.OBR_F1_C1 = @obr_set_id

                    BEGIN TRY
                        ;WITH cte AS (
                            SELECT a.MessageID,
                                a.OBR_IDX,
                                a.SET_ID,
                                a.RESULT_STATUS,
                                cbr.object_id AS obr_object_id,
                                a.obr_service_id,
                                a.SPECIMEN_NUM,
                                a.PROCEDURE_ID,
                                a.next_OBR_IDX
                                FROM
                                (
                                    SELECT OBR.MessageID,
                                        OBR.IDX                                        AS OBR_IDX,
                                        OBR.OBR_F1_C1                                  AS SET_ID,
                                        OBR.OBR_F25_C1                                 AS RESULT_STATUS,
                                        OBR.OBR_F4_C1                                  AS obr_service_id,
                                        OBR.OBR_F3_C1                                  AS SPECIMEN_NUM,
                                        OBR.OBR_F4_C1                                  AS PROCEDURE_ID,
                                        LEAD(OBR.IDX, 1, 9999) OVER (ORDER BY OBR.IDX) AS next_OBR_IDX
                                    FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
                                    WHERE OBR.MessageID = @MessageId
                                ) a
                            INNER JOIN labkey.snprc_ehr.HL7_OBR AS cbr
                                        ON a.MessageID = cbr.MESSAGE_ID  AND cbr.SET_ID = a.SET_ID
                            WHERE a.MessageID = @MessageId AND a.SET_ID = @obr_set_id
                    )

                        UPDATE cpx
                        SET -- cpx.MESSAGE_ID = ,				-- leave intact (needed to join with obr data)
                            -- cpx.SET_ID = ,					-- ditto (needed for ordering data)
                            -- cpx.VALUE_TYPE = ,				-- ditto (should not change)
                            -- cpx.TEST_ID = ,					-- ditto ditto
                            -- cpx.TEST_NAME ',					-- ditto ditto

                            cpx.RESULT = CASE
                                    WHEN OBX.OBX_F11_C1 = 'D' THEN
                                        NULL
                                    WHEN OBX.OBX_F2_C1 = 'NM'
                                        AND labkey.snprc_ehr.f_isNumeric(OBX.OBX_RESULTDATA) = 1
                                        THEN
                                        CAST(LTRIM(RTRIM(REPLACE(OBX.OBX_RESULTDATA, ' ', ''))) AS DECIMAL(10, 3))
                                    ELSE
                                        NULL
                                END,
                            cpx.QUALITATIVE_RESULT = CASE
                                    WHEN OBX.OBX_F11_C1 = 'D' THEN
                                        'RESULT DELETED'
                                    ELSE
                                        OBX.OBX_RESULTDATA
                                END,
                            -- cpx.UNITS = ,					-- leave intact (should not change)
                            -- cpx.REFERENCE_RANGE ,			-- ditto ditto
                            cpx.ABNORMAL_FLAGS = CASE
                                    WHEN OBX.OBX_F11_C1 = 'D' THEN
                                        NULL
                                    ELSE
                                        OBX.OBX_F8_C1
                                END --,
                            --cpx.RESULT_STATUS = OBX.OBX_F11_C1
                        FROM labkey.snprc_ehr.HL7_OBX AS cpx
                                    INNER JOIN labkey.snprc_ehr.HL7_OBR AS cbr ON OBR_OBJECT_ID = @obr_object_id --cpx.OBR_OBJECT_ID = cbr.OBJECT_ID
                                    INNER JOIN cte
                                            ON cbr.SPECIMEN_NUM = cte.SPECIMEN_NUM AND cbr.PROCEDURE_ID = cte.PROCEDURE_ID
                                                AND cbr.RESULT_STATUS = 'F'
                                                AND cte.SET_ID = @obr_set_id
                                    INNER JOIN Orchard_hl7_staging.dbo.ORC_Segment_OBX_A AS OBX
                                            ON cte.MessageID = OBX.MessageID AND OBX.OBX_F3_C1 = cpx.TEST_ID
                                                AND OBX.IDX > cte.OBR_IDX AND OBX.IDX < cte.next_OBR_IDX

                                -- only update data with obx result_status = 'C' or 'D' (corrected or deleted entries)
                        WHERE RTRIM(LTRIM(OBX.OBX_F11_C1)) IN ('C', 'D')

                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                    =
                                'Error processing message: *' + @MessageId + '* for update of HL7_OBX.' + CHAR(13) + CHAR(10)
                                    + ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;
                    -- ADD NTE record with correction notice
                    BEGIN TRY
                        INSERT INTO labkey.snprc_ehr.HL7_NTE

                        (MESSAGE_ID,
                            IDX,
                            OBR_OBJECT_ID,
                            SET_ID,
                            OBR_SET_ID,
                            COMMENT,
                            Container)
                            (SELECT @MessageId,
                                    cbr.IDX    AS IDX,
                                    cbr.OBJECT_ID,
                                    a.SET_ID   AS SET_ID,
                                    cbr.SET_ID AS OBR_SET_ID,
                                    'Corrected: ' + CAST(dbo.f_format_hl7_date(a.OBSERVATION_DATE_TM) AS VARCHAR(50)),
                                    @container as Container
                                FROM (SELECT OBR.MessageID,
                                            OBR.IDX        AS OBR_IDX,
                                            OBR.OBR_F1_C1  AS SET_ID,
                                            OBR.OBR_F25_C1 AS RESULT_STATUS,
                                            OBR.OBR_F3_C1  AS SPECIMEN_NUM,
                                            OBR.OBR_F4_C1  AS PROCEDURE_ID,
                                            OBR.OBR_F7_C1  AS OBSERVATION_DATE_TM
                                    FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
                                    WHERE OBR.MessageID = @MessageId) a
                                        INNER JOIN labkey.snprc_ehr.HL7_OBR AS cbr
                                                    ON cbr.OBJECT_ID = @obr_object_id
                                WHERE RTRIM(LTRIM(a.RESULT_STATUS)) IN ('C', 'D'))

                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                    =
                                'Error inserting Update comment for : *' + @MessageId + '* into HL7_NTE.' + CHAR(13) + CHAR(10) +
                                ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;

                    -- if result status in 'C', 'D' then remove the OBR record
                    BEGIN TRY
                        DELETE
                        FROM labkey.snprc_ehr.HL7_OBR
                        WHERE MESSAGE_ID IN (@MessageId)
                            AND RTRIM(LTRIM(RESULT_STATUS)) IN ('C', 'D')
                    END TRY
                    BEGIN CATCH
                        SELECT @error = -101;
                        SELECT @errormsg
                                    = 'Error deleting message: *' + @MessageId + '* from ORC.' + CHAR(13) + CHAR(10) +
                                        ERROR_MESSAGE();
                        GOTO error;
                    END CATCH;
                END
            END
		SET @ctr = @ctr + 1
        FETCH NEXT FROM @msgCursor INTO @hl7_result_status, @obr_set_id
    END; -- WHILE LOOP

    CLOSE @msgCursor
    DEALLOCATE @msgCursor

	-- Ignore preliminary results @hl7_result_status = 'P'
    -- Since, no observations were recorded, clean up pv1, pid, orc, and msh tables
    -- a rollback will take care of it
    IF @isPreliminary = 1
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM labkey.snprc_ehr.HL7_OBR AS cbr WHERE cbr.MESSAGE_ID = @messageId)
        BEGIN
            ROLLBACK TRANSACTION trans1;

            SET @errormsg = 'Preliminary Results ignored'
            INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG
                    (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES,
                    HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
            VALUES (@MessageId, @hl7_observation_date_tm, @hl7_message_control_id, 3, @hl7_result_status, @animal_id,
            @hl7_species, @hl7_message_text, @errormsg, @container);

            UPDATE Orchard_hl7_staging.dbo.ORC_HL7Data
            SET Processed     = 1,
                StatusMessage = 'SUCCESS: Processed By p_load_hl7_data.sql'
            WHERE MessageID = @MessageId;

            RETURN 0;
        END
    END
	-- all processing finished write to import log and jump to clean exit routine

	INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG
	(MESSAGE_ID,
		OBSERVATION_DATE_TM,
		MESSAGE_CONTROL_ID,
		IMPORT_STATUS,
		RESULT_STATUS,
		PATIENT_ID,
		SPECIES,
		HL7_MESSAGE_TEXT,
		IMPORT_TEXT,
		Container)
	VALUES (@MessageId, @hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status, @animal_id,
			@hl7_species, @hl7_message_text, 'upload okay.', @container);

	GOTO finis;


not_animal_data:

		INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID,
															 IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES,
															 HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
		VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, 2, @hl7_result_status, @animal_id,
				@hl7_species, @hl7_message_text, 'Not animal data.', @container)


    GOTO finis


error:
    -- an error occurred, rollback the entire transaction.
    ROLLBACK TRANSACTION trans1;

    INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG
    (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES,
     HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
    VALUES (@MessageId, @hl7_observation_date_tm, @hl7_message_control_id, @error, @hl7_result_status, @animal_id,
            @hl7_species, @hl7_message_text, @errormsg, @container);

    UPDATE Orchard_hl7_staging.dbo.ORC_HL7Data
    SET Processed     = 1,
        StatusMessage = 'ERROR: Processed By p_load_hl7_data.sql'
    WHERE MessageID = @MessageId;
    RETURN @error;

-- If no error occurred, commit the entire transaction.
    finis:

    UPDATE Orchard_hl7_staging.dbo.ORC_HL7Data
    SET Processed     = 1,
        StatusMessage = 'SUCCESS: Processed By p_load_hl7_data.sql'
    WHERE MessageID = @MessageId;
    COMMIT TRANSACTION trans1;

    RETURN 0;

END;

--    GRANT
--    EXEC ON LIS.p_load_hl7_data TO hl7_admin;
--    GRANT SELECT ON labkey.core.Containers TO hl7_admin;
--    GRANT SELECT ON labkey.snprc_ehr.HL7_Demographics TO hl7_admin;
--    GRANT
--    EXEC ON labkey.snprc_ehr.f_isNumeric TO hl7_admin;


--    GRANT
--    EXEC ON LIS.p_load_hl7_data TO hl7_admin;
--    GRANT SELECT ON labkey.core.Containers TO hl7_admin;
--    GRANT SELECT ON labkey.snprc_ehr.HL7_Demographics TO hl7_admin;
--    GRANT
--    EXEC ON labkey.snprc_ehr.f_isNumeric TO hl7_admin;

--GO