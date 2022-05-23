USE [animal]
GO
/****** Object:  StoredProcedure [LIS].[p_load_hl7_data]    Script Date: 3/23/2022 11:17:35 AM ******/
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
--    -101           General error
--    @@error        SQL errors
--
-- Changes:
--
-- =================================================================
ALTER PROCEDURE [LIS].[p_load_demographics]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE
        @errno INT,
        @error INTEGER,
        @errormsg VARCHAR(MAX),
        @hl7_messageId VARCHAR(50),
        @hl7_messageControl VARCHAR(50),
        @hl7_processed_date_tm VARCHAR(20),
        @msgCursor CURSOR,

        -- cursor columns:
        @RowId INT,
        @Id VARCHAR(6),
        @Gender VARCHAR(1),
        @BirthDate DATETIME2,
        @DeathDate DATETIME2,
        @Breed VARCHAR(2),
        @Species VARCHAR(MAX),
        @isAlive VARCHAR(1),
        @Sire VARCHAR(6),
        @Dam VARCHAR(6),
        @Modified DATETIME2,
        @ModifiedBy VARCHAR(MAX),
        @Processed INT,
        @ObjectId UNIQUEIDENTIFIER,
        @date DATETIME

    SET @date = GETDATE()
    SET @hl7_processed_date_tm = FORMAT(GETDATE(),'yyyyMMddHHmmss')


    -- Start a new transaction
    SET XACT_ABORT ON;
    begin transaction trans1

        set @msgCursor = CURSOR LOCAL FOR
            SELECT RowId,
                   Id,
                   Gender,
                   BirthDate,
                   DeathDate,
                   Breed,
                   Species,
                   isAlive,
                   Sire,
                   Dam,
                   Modified,
                   ModifiedBy,
                   Processed,
                   ObjectId
            FROM LIS.DemographicsHL7Staging AS h
            WHERE h.Processed = 0
            ORDER BY RowId ASC

            FOR READ ONLY

        OPEN @msgCursor

        FETCH @msgCursor INTO @RowId, @Id, @Gender, @BirthDate, @DeathDate, @Breed, @Species, @isAlive, @Sire, @Dam, @Modified, @ModifiedBy, @Processed, @ObjectId

        WHILE (@@FETCH_STATUS = 0)
            BEGIN
                /*
                     1. You must generate a UNIQUE MessageID. We use a GUID (Select NewID() in MS SQL Works just fine), but any guaranteed unique key value which will fit into the
                     MessageID columns is fine.

                */
                SET @hl7_messageId = NEWID()
                SET @hl7_messageControl = FORMAT(GETDATE(),'yyyyMMddHHmmssffff')

                /*
                     Step 2. (NOTE that steps 2 and 3 are interchangeable). You should then insert the appropriate rows into the <PREFIX>_MessageManifest table. Again this table
                     contains only 3 pertinent columns the MessageID (generated in step 1), the SegmentName (MSH, PID, EVN etc, etc) and the SegmentIDX which is the physical
                     sequence in which each segment should appear in the message. MSH = 1, and so on and so on. There should be 1 row in this table for every HL7 segment
                     which your message contains. This SegmentIDX column is used to link/list the IDX column in the underlying segment data tables.
                */

                BEGIN TRY
                    -- MSH
                    INSERT INTO tac_hl7_staging.dbo.TAC_MessageManifest
                    (
                        MessageID,
                        SegmentName,
                        SegmentIDX
                    )
                    VALUES
                        (   @hl7_messageId, -- MessageID - varchar(50)
                            'MSH', -- SegmentName - varchar(10)
                            1  -- SegmentIDX - int
                        )
                    -- PID
                    INSERT INTO tac_hl7_staging.dbo.TAC_MessageManifest
                    (
                        MessageID,
                        SegmentName,
                        SegmentIDX
                    )
                    VALUES
                        (   @hl7_messageId, -- MessageID - varchar(50)
                            'PID', -- SegmentName - varchar(10)
                            2  -- SegmentIDX - int
                        )
                    -- NTE
                    INSERT INTO tac_hl7_staging.dbo.TAC_MessageManifest
                    (
                        MessageID,
                        SegmentName,
                        SegmentIDX
                    )
                    VALUES
                        (   @hl7_messageId, -- MessageID - varchar(50)
                            'NTE', -- SegmentName - varchar(10)
                            3  -- SegmentIDX - int
                        )
                END TRY
                BEGIN CATCH
                    select @error = @@ERROR
                    SELECT @errormsg = 'Error inserting message: *' + @hl7_messageid + '* during Step 2 ' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
                END CATCH

                /*
                    Step 3. (NOTE that steps 2 and 3 are interchangeable). You then populate the underlying data tables by inserting rows with MessageID (generated in step 1) and IDX
                    (equal to the SegmentIDX from step 2) and then complete the data fields. IMPORTANT NOTE: If you are creating HL7 segment data for a segment which has 2 tables
                    associated with it (Like the IN1 segment or GT1 segment etc) then you must insert a row into BOTH the _A table and the _B table even if you aren't populating
                    any data fields other than the MessageID and the IDX.
                */


                -- Insert row into MSH table (dbo.TAC_Segment_MSH_A)
                BEGIN TRY

                    INSERT INTO tac_hl7_staging.dbo.TAC_Segment_MSH_A
                    (
                        MessageID,
                        IDX,
                        MSH_F3_C1,	-- Sending Application
                        MSH_F4_C1,	-- Sending Facility
                        MSH_F5_C1,	-- Receiving Application
                        MSH_F7_C1,	-- Date/Time ofMessage
                        MSH_F9_C1,	-- Message Type
                        MSH_F9_C2,   -- Trigger Event ID
                        MSH_F10_C1,	-- Message Control ID
                        MSH_F11_C1,	-- Processing ID
                        MSH_F12_C1	-- Version ID (HL7)
                    )
                    VALUES
                        (   @hl7_messageId,
                            1,
                            'TAC',
                            'SNPRC',
                            'HARVEST',
                            @hl7_processed_date_tm,
                            'ADT',	-- Patient Administration
                            'A08',	-- Update patient information (event A08)
                            @hl7_messageControl,
                            'P',		-- Production
                            '2.3'
                        )


                    -- Insert row into the PID table (dbo.TAC_Segment_PID_A)
                    -- ?? Where do Breed and Species go ??

                    INSERT INTO tac_hl7_staging.dbo.TAC_Segment_PID_A
                    (
                        MessageID,
                        IDX,
                        PID_F1_C1,
                        PID_F2_C1,
                        PID_F3_C1,
                        PID_F7_C1,
                        PID_F8_C1,
                        PID_F10_C1,
                        PID_F22_C1,
                        PID_F29_C1,
                        PID_F30_C1
                    )
                    VALUES
                        (   @hl7_messageId, -- MessageID - varchar(50)
                            2,  -- IDX - int
                            '1', -- Set Id
                            @id, -- Patient_id (External ID)
                            @id,	-- Patient_id (Internal ID)
                            FORMAT(@BirthDate,'yyyyMMddHHmm'),	-- Date of Birth
                            @Gender,		-- Sex
                            RTRIM(@Species),	-- Race - Species
                            RTRIM(@Breed),	-- Ethnic Grouop - Breed
                            FORMAT(@DeathDate,'yyyyMMddHHmm'), -- Patient Death Date and Time
                            @isAlive	-- Patient Death Indicator
                        )

                    -- Insert row into the NTE table (dbo.TAC_Segment_NTE_A)
                    INSERT INTO tac_hl7_staging.dbo.TAC_Segment_NTE_A
                    (
                        MessageID,
                        IDX,
                        NTE_F1_C1,
                        NTE_F2_C1,
                        NTE_F3_C1
                    )
                    VALUES
                        (   @hl7_messageId, -- MessageID - varchar(50)
                            3,  -- IDX - int
                            '1', -- NTE_F1_C1 - varchar(20) Set Id
                            'Export Date', -- NTE_F2_C1 - varchar(20) Source of comment
                            FORMAT(GETDATE(),'yyyyMMddHHmmss')  -- NTE_F3_C1 - varchar(max) Comment
                        )
                END TRY
                BEGIN CATCH
                    select @error = @@ERROR
                    SELECT @errormsg = 'Error inserting message: *' + @hl7_messageid + '* during Step 3 ' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
                END CATCH

                /*
                    Step 4. After you have done all of this then you will insert a row into the <PREFIX>_HL7Data table using the MessageID (generated in step 1).
                    ANOTHER IMPORTANT NOTE: If you are creating messages that use HL7 Repeating fields or SubComponent values then make sure that you review the section on HL7
                    Repeating Fields thoroughly.
                */

                -- Insert row into the TAC_HL7Data Table
                BEGIN TRY

                    INSERT INTO tac_hl7_staging.dbo.TAC_HL7Data
                    (
                        MessageID,
                        VendorName,
                        VendorVersion,
                        MsgControl,
                        PartnerAPP,
                        DateLoaded,
                        LastLoaded,
                        LoadCount,
                        MsgType,
                        MsgEvent,
                        Outbound,
                        Inbound,
                        Processed,
                        Warnings,
                        Loaded,
                        SchemaLoaded,
                        StatusMessage,
                        ArchiveID,
                        HL7Format,
                        SegmentCount,
                        MessageSize,
                        HL7Message
                    )
                    VALUES
                        (   @hl7_messageId,        -- MessageID - varchar(50)
                            'TAC',        -- VendorName - varchar(50)
                            '2.3',        -- VendorVersion - varchar(25)
                            @hl7_messageControl,        -- MsgControl - varchar(50)
                            @hl7_messageControl,        -- PartnerAPP - varchar(128) - recommended to use MsgControl ID
                            GETDATE(), -- DateLoaded - datetime
                            GETDATE(), -- LastLoaded - datetime
                            1,         -- LoadCount - int
                            'ADT',        -- MsgType - varchar(20)
                            'A08',        -- MsgEvent - varchar(20)
                            1,         -- Outbound - int
                            0,         -- Inbound - int
                            0,         -- Processed - int
                            0,         -- Warnings - int
                            0,         -- Loaded - int
                            0,         -- SchemaLoaded - int
                            '',        -- StatusMessage - varchar(1024)
                            '',        -- ArchiveID - varchar(50)
                            0,         -- HL7Format - int
                            0,         -- SegmentCount - int
                            0,         -- MessageSize - int
                            ''         -- HL7Message - varchar(max)
                        )
                END TRY
                BEGIN CATCH
                    select @error = @@ERROR
                    SELECT @errormsg = 'Error inserting message: *' + @hl7_messageid + '* during Step 4 ' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
                END CATCH

                /*
                    Step 5. Mark the records in the staging table as processed (0 = unprocessed, 1 = processed)
                */

                -- update staging table
                BEGIN TRY
                    UPDATE h
                    SET Processed = 1
                    FROM animal.LIS.DemographicsHL7Staging AS h
                    WHERE h.ObjectId = @ObjectId
                END TRY
                BEGIN CATCH
                    select @error = @@ERROR
                    SELECT @errormsg = 'Error inserting message: *' + @hl7_messageid + '* during Step 5 ' + CHAR(13)+CHAR(10) + ERROR_MESSAGE()
                    goto error
                END CATCH



                -- next row
                FETCH NEXT FROM @msgCursor INTO @RowId, @Id, @Gender, @BirthDate, @DeathDate, @Breed, @Species, @isAlive, @Sire, @Dam, @Modified, @ModifiedBy, @Processed, @ObjectId

            END

        CLOSE @msgCursor
        DEALLOCATE @msgCursor
        -- Jump over error handling
        GOTO finis

        -- error handling
        error:
    ROLLBACK;

    -- Update error log
    INSERT INTO LIS.HL7ExportErrorLog
    (
        ObjectId,
        ProcessedDateTm,
        MessageControlId,
        PatientId,
        ErrorMsg,
        UserName,
        EntryDateTm
    )
    VALUES
        (   @ObjectId, -- ObjectId of demographics row -- varchar(50)
            GETDATE(), -- PROCESSED_DATE_TM - datetime
            @hl7_messageControl,        -- MESSAGE_CONTROL_ID - varchar(50)
            @Id,				-- PATIENT_ID - varchar(20)
            @errormsg,          -- ERROR_MSG - varchar(max)
            @ModifiedBy,        -- USER_NAME - varchar(128)
            @Modified  -- ENTRY_DATE_TM - datetime
        );

    -- Note to self: XACT_ABORT (set above) will rollback transaction
    THROW 51000, @errormsg, 1

-- If no error occurred, commit the entire transaction.
    finis:
    COMMIT transaction trans1

    RETURN 0

END


GO

-- Table permissions
GRANT EXEC ON LIS.p_load_demographics TO z_labkey;
GRANT VIEW DEFINITION ON LIS.p_load_demographics TO z_labkey;

GO

USE tac_hl7_staging
GO

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_MessageManifest TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_MSH_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_PID_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_NTE_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_HL7Data TO labkey;

GO

USE animal
go