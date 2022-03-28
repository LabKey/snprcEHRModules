USE [tac_hl7_staging]
GO
/****** Object:  StoredProcedure [dbo].[p_load_hl7_data]    Script Date: 3/23/2022 11:17:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:		Terry Hawkins
-- Create date: 3/23/2022
-- Description:	loads demographics from TAC to HL7 data tables
-- Returns:
--     0             Okay
--   -1 thru -99    Reserved by sql server for system errors
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
CREATE PROCEDURE [dbo].[p_load_demographics]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   declare  
      @rowcnt INTEGER,
      @error INTEGER, 
      @errormsg VARCHAR(MAX),
	  @hl7_message_text VARCHAR(MAX),
      @hl7_messageId VARCHAR(50),
	  @hl7_result_status VARCHAR(10),
	  @hl7_processed_date_tm DATETIME,
	  @msgCursor CURSOR
      
	SET @hl7_message_text = 'Could not read message text.'
	SET @hl7_result_status = 'Unproc'
	SET @hl7_processed_date_tm = GETDATE()

	
   -- Start a new transaction
   begin transaction trans1

      set @msgCursor = CURSOR FOR
      SELECT *
         from animal.LIS.DemographicsHL7

         order by id asc, move_date_tm desc 
      for read only
   open @location_cursor

   -- Check for nulls in non-nullable columns
   if @hl7_MessageId is Null
   begin
      select @error = -100
	  SELECT @errormsg = 'MessageId is required'
      goto error
   END
   

    IF NOT Exists (Select MessageID From dbo.tac_HL7Data Where MessageID = @MessageID)
	BEGIN 
		SELECT @error = -100
		SELECT @errormsg = 'MessageId not found in the lab_HL7Data table.'
		GOTO error
	END
	BEGIN TRY
		SELECT @hl7_message_text = hl7Message, @hl7_message_control_id = MsgControl FROM dbo.LAB_HL7Data WHERE MessageID = @messageId
		SELECT @hl7_result_status = OBR_F25_C1, @hl7_observation_date_tm = dbo.f_format_hl7_date(OBR_F7_C1) FROM dbo.LAB_Segment_OBR_A WHERE MessageID = @messageId
	
		-- make sure we are working with an animal record
		SELECT @hl7_species = pid.PID_F5_C1, 
			   @patient_id = pid.PID_F2_C1,
			   @animal_id = right('      ' + LTRIM(RTRIM(pid.PID_F2_C1)),6) FROM dbo.LAB_Segment_PID_A AS pid WHERE pid.MessageID = @MessageId
	END TRY
	BEGIN CATCH
		SELECT @error = -101
		SELECT @errormsg = 'Error reading HL7 message data from staging database.'
		GOTO error
	END CATCH

	IF NOT EXISTS (SELECT 1 FROM animal.dbo.master AS m WHERE m.id = @animal_id)
	BEGIN

		SET @pos = PATINDEX('%[ -9][ -9][0-9][.][0-9][0-9]', @patient_id) -- pattern match a location code

		IF @pos = 0 
			SET @pos = PATINDEX('%[ -9][0-9][.][0-9][0-9]', @patient_id)
		IF @pos = 0 
			SET @pos = PATINDEX('%[0-9][.][0-9][0-9]', @patient_id)
		IF @pos >= 1
		begin
			SET @animal_id = LTRIM(SUBSTRING(@patient_id, @pos, LEN(@patient_id) - (@pos-1) ))
			IF (SELECT COUNT(*) FROM animal.dbo.valid_locations AS vl WHERE vl.location = CAST(@animal_id as numeric(6,2)) ) < 1
			   GOTO not_animal_data	-- The sample is not for an animal or a location
		END 
	END

-- This section removes cancelled orders from the animal DB tables
-- OBR result status = 'X' Order cancelled
-- LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'

	IF @hl7_result_status = 'X'
	BEGIN
		BEGIN TRY	
		
		-- remove observations
			DELETE cpx
			
			FROM animal.dbo.clinical_path_obx AS cpx
			JOIN animal.dbo.clinical_path_obr AS cpr ON cpr.MESSAGE_ID = cpx.MESSAGE_ID
			JOIN dbo.LAB_segment_pv1_a AS pv1 ON pv1.messageID = @MessageId
			JOIN dbo.LAB_segment_obr_a AS obr ON obr.messageID = @MessageId
			WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
			  AND cpr.PV1_VISIT_NUM = obr.OBR_F3_C1	
			  AND cpr.SPECIMEN_NUM = obr.OBR_F3_C2
			  AND cpr.Set_ID = obr.OBR_F3_C3		

		END TRY	
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from animal.dbo.clinical_path_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
			goto error
		END CATCH


		-- remove notes
		BEGIN TRY
			DELETE cpn
			
			FROM animal.dbo.clinical_path_nte AS cpn
			JOIN animal.dbo.clinical_path_obr AS cpr ON cpr.MESSAGE_ID = cpn.MESSAGE_ID
			JOIN dbo.LAB_segment_pv1_a AS pv1 ON pv1.messageID = @MessageId
			JOIN dbo.LAB_segment_obr_a AS obr ON obr.messageID = @MessageId
			WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
			  AND cpr.PV1_VISIT_NUM = obr.OBR_F3_C1	
			  AND cpr.SPECIMEN_NUM = obr.OBR_F3_C2
			  AND cpr.Set_ID = obr.OBR_F3_C3	
		END TRY	
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error deleting message: *' + @messageid + '* from animal.dbo.clinical_path_NTE.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
			goto error
		END CATCH
					
			
		-- update observation request
		BEGIN TRY
			UPDATE cpr
			SET RESULT_STATUS = 'X'
			
			FROM animal.dbo.clinical_path_obr AS cpr
			JOIN dbo.LAB_segment_pv1_a AS pv1 ON pv1.messageID = @MessageId
			JOIN dbo.LAB_segment_obr_a AS obr ON obr.messageID = @MessageId
			WHERE LTRIM(RTRIM(obr.OBR_F25_C1)) = 'X'	-- Result_status = Order cancelled
			  AND cpr.PV1_VISIT_NUM = obr.OBR_F3_C1	
			  AND cpr.SPECIMEN_NUM = obr.OBR_F3_C2
			  AND cpr.Set_ID = obr.OBR_F3_C3	
		
		END TRY	
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error updating message: *' + @messageid + '* from animal.dbo.clinical_path_OBR.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
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
			INSERT INTO animal.dbo.clinical_path_OBR
				( MESSAGE_ID ,
					MESSAGE_CONTROL_ID ,
					ANIMAL_ID ,
					VERIFIED_DATE_TM,
					REQUESTED_DATE_TM ,
					OBSERVATION_DATE_TM ,
					SPECIMEN_RECEIVED_DATE_TM, 
					PV1_VISIT_NUM,
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
				msh.MSH_F10_C1,
				@animal_id,
				--CAST(pid.PID_F2_C1 AS VARCHAR(6)),
				dbo.f_format_hl7_date(obr.OBR_F22_C1), -- verified_date_tm
				dbo.f_format_hl7_date(obr.OBR_F6_C1),  -- requested_date_tm
				dbo.f_format_hl7_date(obr.OBR_F7_C1),  -- observation_date_tm
				dbo.f_format_hl7_date(obr.OBR_F14_C1), -- specimen_received_date_tm
				obr.OBR_F3_C1,
				obr.OBR_F3_C3,
				obr.OBR_F2_C1,
				obr.OBR_F4_C1,
				CASE WHEN obr.OBR_F4_C2 = 'OVA' THEN 'OVA & PARASITES' ELSE obr.OBR_F4_C2 END,
				obr.OBR_F5_C1,
				LTRIM(RTRIM(obr.OBR_F25_C1)),
				obr.OBR_F34_C0,	
				obr.OBR_F34_C2,
				pv1.PV1_F3_C4		--charge_id

			
			FROM dbo.LAB_segment_obr_a AS obr
			JOIN dbo.LAB_segment_pid_a AS pid ON pid.MessageID = obr.MessageID
			JOIN dbo.LAB_Segment_MSH_A AS msh ON msh.MessageID = obr.MessageID
			JOIN dbo.LAB_Segment_PV1_A AS pv1 ON pv1.MessageID = obr.MessageID
			-- only load rows for animal_ids in master
			--JOIN dbo.master AS m ON right('      '+ LTRIM(RTRIM(pid.PID_F2_C1)),6)   = m.id
			JOIN dbo.LAB_HL7Data AS h ON h.MessageID = obr.MessageID
			-- ignore rows that are currently being processed
			WHERE obr.MessageId = @MessageId
			  AND LTRIM(RTRIM(obr.OBR_F25_C1)) = 'F'
		END TRY	
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into animal.dbo.clinical_path_OBR.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
			goto error
		END CATCH



		BEGIN TRY
			INSERT INTO animal.dbo.clinical_path_OBX
					( MESSAGE_ID ,
						SET_ID ,
						VALUE_TYPE ,
						TEST_ID ,
						TEST_NAME ,
						OBSERVED_VALUE ,
						UNITS ,
						REFERENCE_RANGE ,
						ABNORMAL_FLAGS ,
						RESULT_STATUS
					)

			SELECT obx.MessageID,
					obx.OBX_F1_C1,
					obx.OBX_F2_C1,
					obx.OBX_F3_C1,
					obx.OBX_F3_C2,
					obx.OBX_RESULTDATA,
					obx.OBX_F6_C1,
					obx.OBX_F7_C1,
					obx.OBX_F8_C1,
					obx.OBX_F11_C1
			FROM dbo.LAB_segment_obx_a AS obx
			JOIN animal.dbo.clinical_path_OBR AS cpo ON obx.MessageID = cpo.MESSAGE_ID
			WHERE obx.MessageId = @MessageId

			-- only load data with result_status = 'F' (final).  result_status = 'C' (corrected) will be handled later.
				AND cpo.RESULT_STATUS = 'F'
		END TRY
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into animal.dbo.clinical_path_OBX.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
			goto error
		END CATCH

		BEGIN TRY
			INSERT INTO animal.dbo.clinical_path_NTE
					( MESSAGE_ID ,
						SET_ID ,
						COMMENT 
					)
			SELECT nte.MessageID,
					nte.NTE_F1_C1,
					nte.NTE_F3_C1
			FROM dbo.LAB_Segment_NTE_A AS nte
			JOIN animal.dbo.clinical_path_OBR AS cpo ON nte.MessageID = cpo.MESSAGE_ID
			WHERE nte.messageId = @MessageId

		END TRY
		BEGIN CATCH
			select @error = -101
			SELECT @errormsg = 'Error inserting message: *' + @messageid + '* into animal.dbo.clinical_path_NTE.' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
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
				 
		
			FROM dbo.LAB_segment_obr_a AS obr 
			JOIN dbo.LAB_segment_obx_a AS obx ON obr.MessageID = obx.MessageID
			JOIN dbo.LAB_HL7Data AS h ON h.MessageID = obr.MessageID
			JOIN animal.dbo.clinical_path_OBR AS cpr ON cpr.PV1_VISIT_NUM = obr.OBR_F3_C1	
													AND cpr.SPECIMEN_NUM = obr.OBR_F3_C2
													AND cpr.Set_ID = obr.OBR_F3_C3
			join animal.dbo.clinical_path_OBX AS cpx ON cpx.MESSAGE_ID = cpr.MESSAGE_ID AND cpx.set_id = obx.OBX_F1_C1 and cpx.TEST_ID = obx.OBX_F3_C1

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
