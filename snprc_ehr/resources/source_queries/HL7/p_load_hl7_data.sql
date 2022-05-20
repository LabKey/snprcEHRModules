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
CREATE PROCEDURE [dbo].[p_load_hl7_data]
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
	  @patient_id VARCHAR(32)
      @table_prefix VARCHAR(3)

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


    IF NOT Exists (Select MessageID From dbo.ORC_HL7Data Where MessageID = @MessageID)
    BEGIN
        SELECT @error = -100
        SELECT @errormsg = 'MessageId not found in the lab_HL7Data table.'
            GOTO error
        END
    BEGIN TRY
        SELECT @hl7_message_text = hl7Message, @hl7_message_control_id = MsgControl FROM dbo.ORC_HL7Data WHERE MessageID = @messageId
        SELECT @hl7_result_status = OBR_F25_C1, @hl7_observation_date_tm = dbo.f_format_hl7_date(OBR_F7_C1) FROM dbo.ORC_Segment_OBR_A WHERE MessageID = @messageId

        -- make sure we are working with an animal record
        SELECT @hl7_species = pid.PID_F10_C1,
               @patient_id = pid.PID_F2_C1,
               @animal_id = right('      ' + LTRIM(RTRIM(pid.PID_F2_C1)),6) FROM dbo.ORC_Segment_PID_A AS pid WHERE pid.MessageID = @MessageId
    END TRY
    BEGIN CATCH
        SELECT @error = -101
        SELECT @errormsg = 'Error reading HL7 message data from staging database.'
            GOTO error
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
-- LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'

	IF @hl7_result_status = 'X'
    BEGIN
        BEGIN TRY
            -- remove observations
                DELETE cpx

                FROM labkey.snprc_ehr.HL7_OBX_Staging AS cpx
                JOIN labkey.snprc_ehr.HL7_OBR_Staging AS cpr ON cpr.MESSAGE_ID = cpx.MESSAGE_ID AND cpr.SET_ID = cpx.OBR_SET_ID
                JOIN dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND obr.OBR_F1_C1 = cpx.OBR_SET_ID
                WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
        END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from HL7_OBX_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
        goto error
    END CATCH

		-- remove notes
    BEGIN TRY
        DELETE cpn

        FROM labkey.snprc_ehr.HL7_NTE_Staging AS cpn
        JOIN labkey.snprc_ehr.HL7_OBR_Staging AS cpr ON cpr.MESSAGE_ID = cpn.MESSAGE_ID AND cpr.SET_ID = cpn.OBR_SET_ID
        JOIN dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND AND obr.OBR_F1_C1 = cpn.OBR_SET_ID
        WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from HL7_NTE_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
            goto error
    END CATCH

		-- update observation request
    BEGIN TRY
        UPDATE cpr
        SET RESULT_STATUS = 'X'

        FROM labkey.snprc_ehr.HL7_OBR_Staging AS cpr
        JOIN dbo.ORC_segment_obr_a AS obr ON obr.messageID = @MessageId AND cpr.Set_ID = obr.OBR_F1_C1
        WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled

    END TRY
    BEGIN CATCH
        select @error = -101
        SELECT @errormsg = 'Error updating message: *' + @messageid + '* from HL7_OBR_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
            goto error
    END CATCH

		-- all processing finished jump to clean exit routine

    INSERT INTO animal.dbo.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID,
			IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT)
		VALUES (@messageId,@hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status,
			@animal_id, @hl7_species, @hl7_message_text, 'Record cancelled: okay.')

		GOTO finis
END

-- Process messeges for new results
--
IF @hl7_result_status = 'F' OR @hl7_result_status = 'C' OR @hl7_result_status = 'D'
BEGIN
    BEGIN TRY
        INSERT INTO labkey.snprc_ehr.HL7_OBR_Staging
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
                TECHNICIAN_NAME ,
                TECHNICIAN_INITIALS,
                CHARGE_ID
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
               obr.OBR_F34_C2, -- Technicial Name
               NULL, -- Technician Initials
               pv1.PV1_F24_C1	--charge_id  -- TODO: maps to HL7 Contract Code

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
        SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBR_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                goto error
    END CATCH



    BEGIN TRY
        -- This is a little tricky. The OBR and OBX records match on MessageId; however multiple OBR records can be in a single message.
        -- If that happens, the IDX value of the OBX records that match a given OBR record will be one greater than the OBR's IDX value,
        -- and will increment to be one less than the next OBR's IDX value. The LEAD function is used to get the next OBR.IDX value and 
        -- the OBX records are constrained by the OBR.IDX and OBR.next_OBR_IDX. A CTE is used to select the OBR records.

		;WITH cte AS (

        SELECT OBR.MessageId, OBR.IDX AS OBR_IDX, OBR.OBR_F1_C1 AS SET_ID, OBR.OBR_F25_C1 as RESULT_STATUS,
            LEAD(OBR.IDX, 1, 9999)  OVER (ORDER BY OBR.IDX) AS next_OBR_IDX

        FROM [Orchard_hl7_staging].[dbo].[ORC_Segment_OBR_A] AS OBR
        WHERE OBR.MessageId = @messageId
        ) 

        INSERT INTO labkey.snprc_ehr.HL7_OBX_Staging
           ( MESSAGE_ID ,
               SET_ID ,
               OBR_SET_ID,
               VALUE_TYPE ,
               TEST_ID ,
               TEST_NAME ,
               OBSERVED_VALUE ,
               UNITS ,
               REFERENCE_RANGE , -- TODO: missing reference ranges in Orchard data
               ABNORMAL_FLAGS ,  -- TODO: ditto ditto
               RESULT_STATUS     -- TODO: ditto ditto
           )

            SELECT obx.MessageID,
                   obx.OBX_F1_C1,
                   cte.next_OBR_IDX, -- OBR_SET_ID
                   obx.OBX_F2_C1,
                   obx.OBX_F3_C1,
                   obx.OBX_F3_C2,
                   obx.OBX_RESULTDATA,
                   obx.OBX_F6_C1,
                   obx.OBX_F7_C1,
                   obx.OBX_F8_C1,
                   obx.OBX_F11_C1
            FROM dbo.ORC_segment_obx_a AS obx
			INNER JOIN cte ON OBX.MessageID = cte.MessageID AND obx.IDX > cte.OBR_IDX AND obx.IDX < cte.next_OBR_IDX
            
              -- only load data with result_status = 'F' (final).  result_status = 'C' (corrected) will be handled later.
              AND cte.RESULT_STATUS = 'F'
       
        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBX_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
        END CATCH

        BEGIN TRY
            INSERT INTO labkey.snprc_ehr.HL7_NTE_Staging
                                ( MESSAGE_ID ,
                                    SET_ID ,
                                    COMMENT
                                )
            SELECT nte.MessageID,
                   nte.NTE_F1_C1,
                   nte.NTE_F3_C1
            FROM dbo.ORC_Segment_NTE_A AS nte
                     JOIN labkey.snprc_ehr.HL7_OBR_Staging AS cpo ON nte.MessageID = cpo.MESSAGE_ID
            WHERE nte.messageId = @MessageId

        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into HL7_OBR_Staging.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
        END CATCH


		-- Process messeges for corrected results
		-- RESULT_STATUS = 'C' for corrected entries, 'D' for deleted entries
        Begin TRY
            UPDATE cpx
            SET -- cpx.MESSAGE_ID = ,				-- leave intact (needed to join with obr data)
                -- cpx.SET_ID = ,					-- ditto (needed for ordering data)
                -- cpx.VALUE_TYPE = ,				-- ditto (should not change)
                -- cpx.TEST_ID = ,					-- ditto ditto
                -- cpx.TEST_NAME ',					-- ditto ditto
                cpx.OBSERVED_VALUE = CASE WHEN obx.OBX_F11_C1 = 'D' then '00' else obx.OBX_RESULTDATA END,
                -- cpx.UNITS = ,					-- leave intact (should not change)
                -- cpx.REFERENCE_RANGE ,			-- ditto ditto
                cpx.ABNORMAL_FLAGS = CASE WHEN obx.OBX_F11_C1 = 'D' then NULL else obx.OBX_F8_C1 END,
                cpx.RESULT_STATUS = obx.OBX_F11_C1


                FROM dbo.ORC_segment_obr_a AS obr
                JOIN dbo.ORC_segment_obx_a AS obx ON obr.MessageID = obx.MessageID
                JOIN dbo.ORC_HL7Data AS h ON h.MessageID = obr.MessageID
                JOIN labkey.snprc_ehr.HL7_OBR_Staging AS cpr ON cpr.MESSAGE_ID = obr.MessageId AND cpr.
                AND cpr.SPECIMEN_NUM = obr.OBR_F3_C2
                AND cpr.Set_ID = obr.OBR_F3_C3
                join labkey.snprc_ehr.HL7_OBX_Staging AS cpx ON cpx.MESSAGE_ID = cpr.MESSAGE_ID AND cpx.set_id = obx.OBX_F1_C1 and cpx.TEST_ID = obx.OBX_F3_C1

            WHERE obr.messageID = @MessageId
            -- only load data with result_status = 'C' or 'D' (corrected or deleted entries)
              AND rtrim(ltrim(obr.OBR_F25_C1)) IN ( 'C', 'D')
        END TRY
        BEGIN CATCH
            select @error = -101
            SELECT @errormsg = 'Error processing message: *' + @messageid + '* for update of animal.dbo.clinical_path_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
        END CATCH


		-- all processing finished jump to clean exit routine

INSERT INTO animal.dbo.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT)
		VALUES (@messageId,@hl7_observation_date_tm, @hl7_message_control_id, 1, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'upload okay.')


		GOTO finis
END
not_animal_data:


	INSERT INTO animal.dbo.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT)
	VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, 2, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, 'Not animal data.')

	GOTO finis

error:
	-- an error occurred, rollback the entire transaction.
    rollback transaction trans1

	INSERT INTO animal.dbo.HL7_IMPORT_LOG (MESSAGE_ID, OBSERVATION_DATE_TM, MESSAGE_CONTROL_ID, IMPORT_STATUS, RESULT_STATUS, PATIENT_ID, SPECIES, HL7_MESSAGE_TEXT, IMPORT_TEXT)
	VALUES (@messageId, @hl7_observation_date_tm, @hl7_message_control_id, @error, @hl7_result_status, @animal_id, @hl7_species, @hl7_message_text, @errorMsg)

Update lab_HL7Data Set Processed = 1, StatusMessage = 'ERROR: Processed By p_load_hl7_data_[hellcat\Miami].sql' Where MessageID = @MessageID
    return @error

-- If no error occurred, commit the entire transaction.
finis:

Update lab_HL7Data Set Processed = 1, StatusMessage = 'SUCCESS: Processed By p_load_hl7_data_[hellcat\Miami].sql' Where MessageID = @MessageID
    commit transaction trans1

    return 0



END
