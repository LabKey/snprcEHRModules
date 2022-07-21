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
-- other == SQL server error number
--
-- Changes:
--
-- =================================================================
ALTER PROCEDURE [dbo].[p_load_hl7_data]
(	@MessageId VARCHAR(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   declare
      @rowcnt INTEGER,
      @error INTEGER,
      @errormsg VARCHAR(MAX),
	  @animal_id VARCHAR(7),
	  @hl7_message_text VARCHAR(MAX),
      @hl7_message_control_id VARCHAR(50),
	  @hl7_result_status VARCHAR(10),
	  @hl7_species VARCHAR(50),
	  @hl7_observation_date_tm DATETIME,
	  @pos INT,
	  @patient_id VARCHAR(32),
      @table_prefix VARCHAR(3),
      @container UNIQUEIDENTIFIER


	SET @animal_id = 'Unproc'
	SET @hl7_message_text = 'Could not read message text.'
	SET @hl7_message_control_id = 'Unprocessed.'
	SET @hl7_result_status = 'Unproc'
	SET @hl7_species = 'Unprocessed'
	SET @hl7_observation_date_tm = '01-01-1900 00:00'
    SET @table_prefix = 'ORC'


   -- Start a new transaction
begin transaction trans1

   -- Check for nulls in non-nullable columns
   if @MessageId is Null
    begin
        select @error = -100
        SELECT @errormsg = 'MessageId argument is null.'
            goto error
    END


    IF NOT Exists (Select MessageID From Orchard_hl7_staging.dbo.ORC_HL7Data Where MessageID = @MessageID)
    BEGIN
        SELECT @error = -100
        SELECT @errormsg = 'MessageId not found in the ORC_HL7Data table.'
            GOTO error
    END

    BEGIN TRY
        -- set local variables
        SELECT @hl7_message_text = hl7Message, 
               @hl7_message_control_id = MsgControl 
        FROM dbo.ORC_HL7Data WHERE MessageID = @messageId

        SELECT @hl7_result_status = OBR_F25_C1, 
               @hl7_observation_date_tm = dbo.f_format_hl7_date(OBR_F7_C1) 
        FROM dbo.ORC_Segment_OBR_A WHERE MessageID = @messageId

        -- make sure we are working with an animal record
        SELECT @hl7_species = pid.PID_F10_C1,
               @patient_id = pid.PID_F2_C1,
               @animal_id = LTRIM(RTRIM(pid.PID_F2_C1))
        FROM dbo.ORC_Segment_PID_A AS pid WHERE pid.MessageID = @MessageId

        -- get container id
        SELECT @container = EntityId FROM labkey.core.Containers AS c WHERE c.Name = 'SNPRC'

    END TRY
    BEGIN CATCH
        SELECT @error = -101
        SELECT @errormsg = 'Error reading HL7 message data from staging database.'
            GOTO error
    END CATCH
    --------------------------------------------------------------------------------------------------------
    -- insert into MSH table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_MSH
            (   MESSAGE_ID,
                IDX,
                SENDING_APPLICATION,
                SENDING_FACILITY,
                RECEIVING_APPLICATION,
                RECEIVING_FACILITY,
                MESSAGE_TYPE,
                TRIGGER_EVENT_ID,
                MESSAGE_CONTROL_ID,
                MESSAGE_DATE_TM,
				Container
            )

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

        FROM Orchard_HL7_staging.dbo.ORC_segment_msh_a AS msh
        WHERE msh.MessageId = @messageid
    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_MSH.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH
    --------------------------------------------------------------------------------------------------------
    -- insert into PID table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_PID
        (
            MESSAGE_ID,
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
            Container
        )
        
        (   SELECT 
                pid.MessageId,        -- MESSAGE_ID - varchar(50)
                pid.IDX,              -- IDX - int
                pid.PID_F1_C1,        -- SET_ID - varchar(20)
                pid.PID_F2_C1,        -- PATIENT_ID_EXTERNAL - varchar(20)
                pid.PID_F3_C1,        -- PATIENT_ID_INTERNAL - varchar(20)
                dbo.f_format_hl7_date(pid.PID_F7_C1), -- BIRTHDATE - datetime
                pid.PID_F8_C1,         -- SEX - varchar(20)
                pid.PID_F10_C1,        -- BREED - varchar(50)
                pid.PID_F22_C1,        -- SPECIES - varchar(50)
                pid.PID_F18_C1,        -- ACCOUNT_NUMBER - varchar(50)
                dbo.f_format_hl7_date(pid.PID_F29_C1),
                @container             -- Container
            FROM Orchard_hl7_staging.dbo.ORC_Segment_PID_A as pid
            where pid.messageID = @messageId
        )
    END TRY
        BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_PID.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                goto error
    END CATCH
    --------------------------------------------------------------------------------------------------------
    -- insert into PV1 table
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_PV1
        (
            MESSAGE_ID,
            IDX,
            SET_ID,
            ADMISSION_TYPE,
            ATTENDING_DOCTOR_LAST,
            ATTENDING_DOCTOR_FIRST,
            VISIT_NUMBER,
            CHARGE_NUMBER,
            ADMIT_DATE,
            Container
        )
        ( 
            SELECT
                pv1.messageId,        -- MESSAGE_ID - varchar(50)
                pv1.IDX,         -- IDX - int
                pv1.PV1_F1_C1,        -- SET_ID - varchar(20)
                pv1.PV1_F4_C1,        -- ADMISSION_TYPE - varchar(20)
                pv1.PV1_F7_C2,        -- ATTENDING_DOCTOR_LAST - varchar(50)
                pv1.PV1_F7_C3,        -- ATTENDING_DOCTOR_FIRST - varchar(50)
                pv1.PV1_F19_C1,        -- VISIT_NUMBER - varchar(20)
                pv1.PV1_F22_C1,        -- CHARGE_NUMBER - varchar(20)
                dbo.f_format_hl7_date(pv1b.PV1_F44_C1), -- ADMIT_DATE
                @container             -- Container
            FROM Orchard_HL7_staging.dbo.ORC_Segment_PV1_A as pv1
			INNER JOIN Orchard_hl7_staging.dbo.ORC_Segment_PV1_B AS pv1b ON pv1b.MessageID = pv1.MessageID AND pv1b.IDX = pv1.IDX
            WHERE pv1.MessageId = @messageId
        )
    END TRY
        BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_PV1.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

    --------------------------------------------------------------------------------------------------------
    -- insert into OCR table

    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_ORC
        (
            MESSAGE_ID,
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
            Container
        )
        ( SELECT
                orc.MessageId,        -- MESSAGE_ID - varchar(50)
                orc.IDX,             -- IDX - int
                orc.ORC_F1_C1,        -- ORDER_CONTROL_CODE - varchar(20)
                orc.ORC_F3_C1,        -- FILLER_ORDER_NUMBER - varchar(22)
                orc.ORC_F10_C2,        -- ENTERED_BY_LAST - varchar(50)
                orc.ORC_F10_C3,        -- ENTERED_BY_FIRST - varchar(50)
                orc.ORC_F11_C2,        -- VERIFIED_BY_LAST - varchar(50)
                orc.ORC_F11_C3,        -- VERIFIED_BY_FIRST - varchar(50)
                orc.ORC_F12_C2,        -- ORDER_PROVIDER_LAST - varchar(50)
                orc.ORC_F12_C3,        -- ORDER_PROVIDER_FIRST - varchar(50)
                orc.ORC_F14_C3,        -- CALLBACK_EMAIL - varchar(50)
                dbo.f_format_hl7_date(orc.ORC_F15_C1), -- ORDER_DATE - datetime
                @container             -- Container
                
            FROM Orchard_HL7_staging.dbo.ORC_Segment_ORC_A as orc
            WHERE orc.MessageId = @messageId
            )
    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_ORC.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

-- TODO: which table do we want to use as the demographics source - using Marvin.labkey database for development
-- TODO: Do we want to import data for location pool samples? Section is commented out for now
--     IF NOT EXISTS (SELECT 1 FROM labkey.StudyDataSet.c6d340_demographics AS m WHERE m.participantid = @animal_id)
--     BEGIN
--        SET @pos = PATINDEX('%[ -9][ -9][0-9][.][0-9][0-9]', @patient_id) -- pattern match a location code
--        IF @pos = 0
--            SET @pos = PATINDEX('%[ -9][0-9][.][0-9][0-9]', @patient_id)
--        IF @pos = 0
--            SET @pos = PATINDEX('%[0-9][.][0-9][0-9]', @patient_id)
--        IF @pos >= 1
--            begin
--                 SET @animal_id = LTRIM(SUBSTRING(@patient_id, @pos, LEN(@patient_id) - (@pos-1) ))
--                 IF (SELECT COUNT(*) FROM animal.dbo.valid_locations AS vl WHERE vl.location = CAST(@animal_id as numeric(6,2)) ) < 1
--                    GOTO not_animal_data	-- The sample is not for an animal or a location
--            END
--     END


-- TODO: currently using database: Marvin.labkey for development
-- This section removes cancelled orders from the animal DB tables
-- OBR result status = 'X' Order cancelled

	IF @hl7_result_status = 'X'
    BEGIN
        BEGIN TRY
            -- remove observations
                DELETE cpx

                FROM labkey.snprc_ehr.HL7_OBX AS cpx
                INNER JOIN labkey.snprc_ehr.HL7_OBR AS cpr ON cpr.OBJECT_ID = cpx.OBR_OBJECT_ID
                INNER JOIN Orchard_hl7_staging.dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND obr.OBR_F1_C1 = cpx.OBR_SET_ID
                WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
        END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from HL7_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

		-- remove notes
    BEGIN TRY
        DELETE cpn

        FROM labkey.snprc_ehr.HL7_NTE AS cpn
        JOIN labkey.snprc_ehr.HL7_OBR AS cpr ON cpr.OBJECT_ID = cpn.OBR_OBJECT_ID
        JOIN dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND obr.OBR_F1_C1 = cpn.OBR_SET_ID
        WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from HL7_NTE.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

		-- update observation request
    BEGIN TRY
        UPDATE cpr
        SET RESULT_STATUS = 'X'

        FROM labkey.snprc_ehr.HL7_OBR AS cpr
        JOIN dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND cpr.Set_ID = obr.OBR_F1_C1
        WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled

    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error updating message: *' + @messageid + '* from HL7_OBR.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

		-- all processing finished jump to clean exit routine

    INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID,
			IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
		VALUES (@messageId,@hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status,
			@animal_id, @hl7_species, @hl7_message_text, 'Record cancelled: okay.', @container)

		GOTO finis
END

-- Process messeges for new results
--
IF @hl7_result_status = 'F' OR @hl7_result_status = 'C' OR @hl7_result_status = 'D'
BEGIN
    -- RESULT_STATUS = 'F'
    DECLARE @obr_object_id UNIQUEIDENTIFIER
    DECLARE @ObjectId_TableVar TABLE (ObjectId UNIQUEIDENTIFIER, tid INT Identity)


    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_OBR
            
            ( MESSAGE_ID ,
                IDX,
                MESSAGE_CONTROL_ID ,
                ANIMAL_ID ,
                VERIFIED_DATE_TM,
                REQUESTED_DATE_TM ,
                OBSERVATION_DATE_TM ,
                SPECIMEN_RECEIVED_DATE_TM,
                SET_ID,
                SPECIMEN_NUM ,
                PROCEDURE_ID ,
                PROCEDURE_NAME ,
                PRIORITY ,
                RESULT_STATUS ,
                TECHNICIAN_LAST_NAME ,
                TECHNICIAN_FIRST_NAME,
                CHARGE_ID,
                OBJECT_ID,
                Container
            ) 

        SELECT obr.MessageID,
               obr.IDX,
               msh.MSH_F10_C1,
               @animal_id,
               dbo.f_format_hl7_date(obr.OBR_F22_C1), -- verified_date_tm
               dbo.f_format_hl7_date(obr.OBR_F6_C1),  -- requested_date_tm
               dbo.f_format_hl7_date(obr.OBR_F7_C1),  -- observation_date_tm
               dbo.f_format_hl7_date(obr.OBR_F14_C1), -- specimen_received_date_tm
               obr.OBR_F1_C1, -- Set_ID
               obr.OBR_F3_C1, --Filler Order Number
               obr.OBR_F4_C1, -- Procedure ID
               obr.OBR_F4_C2, -- Procedure Name
               obr.OBR_F5_C1, -- Priority
               LTRIM(RTRIM(obr.OBR_F25_C1)), -- Result status
               obr.OBR_F34_C1, -- Technician last name
               obr.OBR_F34_C2, -- Technician first name
               pv1.PV1_F24_C1,	--charge_id  -- TODO: maps to HL7 Contract Code
               NEWID(), -- object_ID
               @container

        FROM dbo.ORC_segment_obr_a AS obr
        JOIN dbo.ORC_segment_pid_a AS pid ON pid.MessageID = obr.MessageID
        JOIN dbo.ORC_Segment_MSH_A AS msh ON msh.MessageID = obr.MessageID
        JOIN dbo.ORC_Segment_PV1_A AS pv1 ON pv1.MessageID = obr.MessageID
            -- only load rows for animal_ids in master
            --JOIN dbo.master AS m ON right('      '+ LTRIM(RTRIM(pid.PID_F2_C1)),6)   = m.id
        JOIN dbo.ORC_HL7Data AS h ON h.MessageID = obr.MessageID
             -- ignore rows that are currently being processed
        WHERE obr.MessageId = @MessageId
          AND LTRIM(RTRIM(obr.OBR_F25_C1)) = 'F'
    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBR.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH



    BEGIN TRY
        -- This is a little tricky. The OBR and OBX records match on MessageId; however multiple OBR records can be in a single message.
        -- If that happens, the IDX value of the OBX records that match a given OBR record will be one greater than the OBR's IDX value,
        -- and will increment to be one less than the next OBR's IDX value. The LEAD function is used to get the next OBR.IDX value and 
        -- the OBX records are constrained by the OBR.IDX and OBR.next_OBR_IDX. A CTE is used to select the OBR records.

        -- get OBR's ObjectId
        select @obr_object_id = (select ObjectId from @ObjectId_TableVar
                                    WHERE tid = (SELECT MAX(tid) from @ObjectId_TableVar))
        -- New OBX records
		;WITH cte AS (

            SELECT OBR.MessageId, OBR.IDX AS OBR_IDX, OBR.OBR_F1_C1 AS SET_ID, OBR.OBR_F25_C1 as RESULT_STATUS, cbr.OBJECT_ID as obr_object_id,
                   obr.OBR_F4_C1 as obr_service_id,
                LEAD(OBR.IDX, 1, 9999)  OVER (ORDER BY OBR.IDX) AS next_OBR_IDX

            FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
            INNER JOIN labkey.snprc_ehr.HL7_OBR as cbr on OBR.messageId = cbr.Message_ID and OBR.OBR_F1_C1 = cbr.SET_ID
			INNER JOIN labkey.core.Containers AS c ON c.Name = 'SNPRC'
            WHERE OBR.MessageId = @messageId
        ) 

        INSERT INTO labkey.snprc_ehr.HL7_OBX
           ( MESSAGE_ID ,
               IDX,
               OBR_OBJECT_ID,
               SET_ID,
               OBR_SET_ID,
               VALUE_TYPE ,
               TEST_ID ,
               TEST_NAME ,
               serviceTestId,
               QUALITATIVE_RESULT,
               RESULT,
               UNITS ,
               REFERENCE_RANGE ,
               ABNORMAL_FLAGS ,
               RESULT_STATUS,
               Container
           ) -- output Inserted.OBR_OBJECT_ID

            SELECT obx.MessageID,
                   obx.IDX,
                   cte.obr_object_id,
                   obx.OBX_F1_C1,
                   cte.SET_ID, -- OBR SET ID
                   obx.OBX_F2_C1,
                   obx.OBX_F3_C1,
                   obx.OBX_F3_C2,
                   lp.objectId,
                   obx.OBX_RESULTDATA,
                   CASE WHEN obx.OBX_F2_C1 = 'NM' AND labkey.snprc_ehr.f_isNumeric(obx.OBX_RESULTDATA) = 1
                            THEN CAST(LTRIM(RTRIM(REPLACE(obx.OBX_RESULTDATA, ' ', ''))) AS DECIMAL(10, 3))
                    ELSE NULL END AS RESULT,
                   obx.OBX_F6_C1,
                   obx.OBX_F7_C1,
                   obx.OBX_F8_C1,
                   obx.OBX_F11_C1,
                   @container
            FROM dbo.ORC_segment_obx_a AS obx
			INNER JOIN cte ON OBX.MessageID = cte.MessageID AND obx.IDX > cte.OBR_IDX AND obx.IDX < cte.next_OBR_IDX
			LEFT OUTER JOIN labkey.snprc_ehr.labwork_panels AS lp ON cte.obr_service_id = lp.serviceId
			        AND obx.OBX_F3_C1 = lp.testId
            
              -- only load data with result_status = 'F' (final).
              AND cte.RESULT_STATUS = 'F'
       
        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
            goto error
        END CATCH

        -- New NTE records
        BEGIN TRY
		;WITH cte AS (

            SELECT OBR.MessageId, OBR.IDX AS OBR_IDX, OBR.OBR_F1_C1 AS SET_ID, OBR.OBR_F25_C1 as RESULT_STATUS, cbr.OBJECT_ID as obr_object_id,
                LEAD(OBR.IDX, 1, 9999)  OVER (ORDER BY OBR.IDX) AS next_OBR_IDX

            FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
            INNER JOIN labkey.snprc_ehr.HL7_OBR as cbr on OBR.messageId = cbr.Message_ID and OBR.OBR_F1_C1 = cbr.SET_ID
            WHERE OBR.MessageId = @messageId
        ) 
            INSERT INTO labkey.snprc_ehr.HL7_NTE
                ( MESSAGE_ID ,
                    IDX,
                    OBR_OBJECT_ID,
                    SET_ID,
                    OBR_SET_ID,
                    COMMENT,
					Container
                )
            SELECT nte.MessageID,
                   nte.IDX,
                   cte.obr_object_id,
                   nte.NTE_F1_C1,
                   cte.SET_ID, -- OBR_SET_ID
                   nte.NTE_F3_C1,
				   @container
            FROM Orchard_hl7_staging.dbo.ORC_Segment_NTE_A AS nte
            INNER JOIN cte ON nte.MessageID = cte.messageId AND nte.IDX > cte.OBR_IDX AND nte.IDX < cte.next_OBR_IDX
            -- only load data with result_status = 'F' (final).
              AND cte.RESULT_STATUS = 'F'
        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBR.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
            goto error
        END CATCH


		-- Process messeges for corrected results
		-- RESULT_STATUS = 'C' for corrected entries, 'D' for deleted entries
        -- OBR entries don't change
        Begin TRY
		;WITH cte AS (

            SELECT OBR.MessageId, OBR.IDX AS OBR_IDX, OBR.OBR_F1_C1 AS SET_ID, OBR.OBR_F25_C1 as RESULT_STATUS, cbr.OBJECT_ID as obr_object_id,
                LEAD(OBR.IDX, 1, 9999)  OVER (ORDER BY OBR.IDX) AS next_OBR_IDX

            FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
            INNER JOIN labkey.snprc_ehr.HL7_OBR as cbr on OBR.messageId = cbr.Message_ID and OBR.OBR_F1_C1 = cbr.SET_ID
            WHERE OBR.MessageId = @messageId
        ) 

            UPDATE cpx
            SET -- cpx.MESSAGE_ID = ,				-- leave intact (needed to join with obr data)
                -- cpx.SET_ID = ,					-- ditto (needed for ordering data)
                -- cpx.VALUE_TYPE = ,				-- ditto (should not change)
                -- cpx.TEST_ID = ,					-- ditto ditto
                -- cpx.TEST_NAME ',					-- ditto ditto

                cpx.RESULT = CASE WHEN obx.OBX_F11_C1 = 'D' then '00'
                    else
                        CASE WHEN obx.OBX_F2_C1 = 'NM' AND labkey.snprc_ehr.f_isNumeric(obx.OBX_RESULTDATA) = 1
                        THEN CAST(LTRIM(RTRIM(REPLACE(obx.OBX_RESULTDATA, ' ', ''))) AS DECIMAL(10, 3))
                        ELSE
                            NULL
                        END
                    END,
                
                cpx.QUALITATIVE_RESULT = CASE WHEN obx.OBX_F11_C1 = 'D' THEN '00' ELSE obx.OBX_RESULTDATA END,
                -- cpx.UNITS = ,					-- leave intact (should not change)
                -- cpx.REFERENCE_RANGE ,			-- ditto ditto
                cpx.ABNORMAL_FLAGS = CASE WHEN obx.OBX_F11_C1 = 'D' then NULL else obx.OBX_F8_C1 END,
                cpx.RESULT_STATUS = obx.OBX_F11_C1

                FROM labkey.snprc_ehr.HL7_OBX AS cpx
                INNER JOIN cte ON cpx.Message_ID = cte.MessageID AND cpx.IDX > cte.OBR_IDX AND cpx.IDX < cte.next_OBR_IDX
                INNER JOIN Orchard_hl7_staging.dbo.ORC_segment_obx_a as OBX on cpx.MESSAGE_ID = OBX.MessageId and cpx.IDX = OBX.IDX
            -- only update data with obx result_status = 'C' or 'D' (corrected or deleted entries)
           WHERE RTRIM(LTRIM(obx.OBX_F11_C1)) in ('C', 'D')

        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error processing message: *' + @messageid + '* for update of HL7_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
            goto error
        END CATCH 
       
		-- all processing finished jump to clean exit routine

        INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
		VALUES (@messageId,@hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'upload okay.', @container)

		GOTO finis
END
not_animal_data:

	INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
	VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, 2, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'Not animal data.', @container)

	GOTO finis

error:
	-- an error occurred, rollback the entire transaction.
    rollback transaction trans1

	INSERT INTO labkey.snprc_ehr.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT, Container)
	VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, @error, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, @errorMsg, @container)

    Update Orchard_hl7_staging.dbo.ORC_HL7Data Set Processed = 1, StatusMessage = 'ERROR: Processed By p_load_hl7_data.sql' Where MessageID = @MessageID
       
    return @error

-- If no error occurred, commit the entire transaction.
finis:

    Update Orchard_hl7_staging.dbo.ORC_HL7Data Set Processed = 1, StatusMessage = 'SUCCESS: Processed By p_load_hl7_data.sql' Where MessageID = @MessageID
    commit transaction trans1

    return 0

END

GRANT EXEC ON LIS.p_load_hl7_data TO hl7_admin;
GRANT SELECT ON labkey.core.Containers TO hl7_admin;
GRANT VIEW DEFINITION ON LIS.p_load_demographics TO hl7_admin;

GO