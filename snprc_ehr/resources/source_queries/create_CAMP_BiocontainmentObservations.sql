/*******************************************************************
Creates a TAC_src landing table + a stored procedure to receive Biocontainment
Observations edits made in TAC, for fan-out into CAMP's live
dbo.BiocontainmentObservations table

 *******************************************************************/

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'TAC_src')
EXEC('CREATE SCHEMA [TAC_src] AUTHORIZATION [DBO]');

DROP TABLE IF EXISTS TAC_src.BiocontainmentObservations;

CREATE TABLE TAC_src.BiocontainmentObservations
(
    tid INT IDENTITY,
    Id VARCHAR(6) NOT NULL,
    ObservationDate DATETIME NOT NULL,
    Location DECIMAL(6,2) NOT NULL,
    WeightLoss INT NULL,
    WeightLoss_CO INT NULL,
    TemperatureChange INT NULL,
    TemperatureChange_CO INT NULL,
    Responsiveness INT NULL,
    HairCoat INT NULL,
    Respiration INT NULL,
    Petechia INT NULL,
    Petechia_CO INT NULL,
    Bleeding INT NULL,
    NasalDischarge INT NULL,
    FeedEaten INT NULL,
    FeedEaten_CO INT NULL,
    FoodEnrichment INT NULL,
    FoodEnrichment_CO INT NULL,
    Stool VARCHAR(2) NULL,
    FluidIntake INT NULL,
    Dehydration INT NULL,
    Dehydration_CO INT NULL,
    Dehydration_NS INT NULL,
    FoundDead INT NULL,
    CageCleaning INT NULL,
    Water INT NULL,
    Comment VARCHAR(80) NULL,
    ETLDownDate DATETIME DEFAULT GETDATE(),
    Created DATETIME NULL,
    CreatedBy INT NULL,
    CreatedByEmail VARCHAR(128) NULL,
    Modified DATETIME NULL,
    ModifiedBy INT NULL,
    ModifiedByEmail VARCHAR(128) NULL,
    Container UNIQUEIDENTIFIER NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL,
    -- The LabKey Modified value of the last version fanned out to CAMP (not a
    -- SQL Server timestamp), so the pending check compares values from the
    -- same clock.
    FannedOutModified DATETIME NULL,
    -- Set when CAMP rejected this row (e.g. a CHECK constraint): the error and
    -- the LabKey Modified value that failed. The row isn't retried until it's
    -- edited again in TAC (Modified moves past FanOutErrorModified).
    FanOutError NVARCHAR(4000) NULL,
    FanOutErrorModified DATETIME NULL,
    CONSTRAINT PK_TAC_BIOCONTAINMENTOBSERVATIONS
        PRIMARY KEY CLUSTERED (tid ASC)
)
GO

-- objectid is the export ETL's merge key and the fan-out's join key, so index
-- it rather than scan the (never-purged) table on every run. Unique also
-- guarantees one landing row per CAMP row, which @matched relies on.
CREATE UNIQUE NONCLUSTERED INDEX IX_TAC_BIOCONTAINMENTOBSERVATIONS_OBJECTID
    ON TAC_src.BiocontainmentObservations (objectid);
GO


DROP PROCEDURE IF EXISTS [TAC_src].[usp_FanOutBiocontainmentObservations];
GO

CREATE PROCEDURE [TAC_src].[usp_FanOutBiocontainmentObservations] AS
-- ==========================================================================================
-- Author:     Ram
-- Create date: 09/10/26
-- Description: Fans TAC edits out of the TAC_src.BiocontainmentObservations landing table into CAMP's
--              live dbo.BiocontainmentObservation table. Called as step2 of the TAC to CAMP
--              export ETL (resources/etls/ExportBiocontainmentObservations.xml), after step1's merge
--              into TAC_src.BiocontainmentObservations has already committed.
--
--              On success, returns a single-row result set of counts for the caller
--              (BiocontainmentObservationsFanOutTask) to write to the ETL log:
--                UpdatedCount   - CAMP rows updated
--                UnchangedCount - rows already matching CAMP, marked fanned out without an update
--                UnmatchedCount - pending rows with no CAMP row for their ObjectId; recorded in
--                                 FanOutError like a rejection and not retried until edited again
--                ConflictCount  - rows skipped because CAMP changed mid-run; retried next run
--                RejectedCount  - rows CAMP rejected with a data error (constraint, NULL,
--                                 truncation, overflow); error saved in FanOutError and the
--                                 row not retried until edited again in TAC
--              Each row is updated in its own transaction, so a rejected row doesn't
--              block the others. Any other error raises and fails the run; rows
--              already committed in that run stay committed.
-- ==========================================================================================
BEGIN
    SET NOCOUNT ON;

    DECLARE @errno  INT,
            @errmsg VARCHAR(255),
            @rowError       INT,
            @updatedCount   INT = 0,
            @unchangedCount INT = 0,
            @unmatchedCount INT = 0,
            @conflictCount  INT = 0,
            @rejectedCount  INT = 0,
            @targetTid      INT,
            @landingTid     INT,
            @rowsUpdated    INT;

    DECLARE @matched TABLE
    (
        targetTid          INT NOT NULL PRIMARY KEY,
        landingTid          INT NOT NULL,
        landingObjectId     UNIQUEIDENTIFIER NOT NULL,
        landingModified     DATETIME NULL,
        capturedTimestamp  BINARY(8) NOT NULL,
        Location            DECIMAL(6,2) NULL,
        WeightLoss          INT NULL,
        WeightLoss_CO       INT NULL,
        TemperatureChange   INT NULL,
        TemperatureChange_CO INT NULL,
        Responsiveness      INT NULL,
        HairCoat            INT NULL,
        Respiration         INT NULL,
        Petechia            INT NULL,
        Petechia_CO         INT NULL,
        Bleeding            INT NULL,
        NasalDischarge      INT NULL,
        FeedEaten           INT NULL,
        FeedEaten_CO        INT NULL,
        FoodEnrichment      INT NULL,
        FoodEnrichment_CO   INT NULL,
        Stool               VARCHAR(2) NULL,
        FluidIntake         INT NULL,
        Dehydration         INT NULL,
        Dehydration_CO      INT NULL,
        Dehydration_NS      INT NULL,
        FoundDead           INT NULL,
        CageCleaning        INT NULL,
        Water               INT NULL,
        Comment             VARCHAR(80) NULL,
        hasChanges          BIT NOT NULL
    );

    -- capturedTimestamp is CAMP's rowversion for this row at match time. The
    -- final UPDATE below only applies if the row's rowversion is still this
    -- value, so a concurrent edit to the same CAMP row (e.g. from the Android
    -- app) between this SELECT and the UPDATE loses the race safely instead
    -- of being silently overwritten - the loser is left unmatched, its
    -- FannedOutModified isn't advanced, and it's picked up again on the next run.
    --
    -- landingModified is the LabKey Modified value being sent; it's what gets
    -- stored in FannedOutModified, so an edit merged into the landing table
    -- after this point still compares as newer and is sent next run.
    --
    -- hasChanges is 0 when applying the landing row (with the same COALESCE /
    -- straight-assignment rules as the UPDATE below) would leave the CAMP row unchanged, e.g. an
    -- approval in TAC or a CAMP row that came back through the import ETL.
    -- EXCEPT compares NULLs as equal.
    INSERT INTO @matched
    SELECT b.tid, l.tid, l.objectid, l.Modified, b.timestamp, l.Location, l.WeightLoss, l.WeightLoss_CO,
           l.TemperatureChange, l.TemperatureChange_CO, l.Responsiveness,
           l.HairCoat, l.Respiration, l.Petechia, l.Petechia_CO, l.Bleeding,
           l.NasalDischarge, l.FeedEaten, l.FeedEaten_CO, l.FoodEnrichment,
           l.FoodEnrichment_CO, l.Stool, l.FluidIntake, l.Dehydration,
           l.Dehydration_CO, l.Dehydration_NS, l.FoundDead, l.CageCleaning, l.Water, l.Comment,
           CASE WHEN EXISTS (
               SELECT COALESCE(l.Location, b.Location), l.WeightLoss, l.WeightLoss_CO, l.TemperatureChange,
                      l.TemperatureChange_CO, l.Responsiveness, l.HairCoat, l.Respiration,
                      l.Petechia, l.Petechia_CO, l.Bleeding, l.NasalDischarge,
                      l.FeedEaten, l.FeedEaten_CO, l.FoodEnrichment, l.FoodEnrichment_CO,
                      l.Stool, l.FluidIntake, l.Dehydration, l.Dehydration_CO,
                      l.Dehydration_NS, l.FoundDead, l.CageCleaning, l.Water,
                      l.Comment
               EXCEPT
               SELECT b.Location, b.WeightLoss, b.WeightLoss_CO, b.TemperatureChange,
                      b.TemperatureChange_CO, b.Responsiveness, b.HairCoat, b.Respiration,
                      b.Petechia, b.Petechia_CO, b.Bleeding, b.NasalDischarge,
                      b.FeedEaten, b.FeedEaten_CO, b.FoodEnrichment, b.FoodEnrichment_CO,
                      b.Stool, b.FluidIntake, b.Dehydration, b.Dehydration_CO,
                      b.Dehydration_NS, b.FoundDead, b.CageCleaning, b.Water,
                      b.Comment
           ) THEN 1 ELSE 0 END
    FROM TAC_src.BiocontainmentObservations l
        INNER JOIN dbo.BiocontainmentObservation b ON b.ObjectId = l.objectid
    WHERE (l.FannedOutModified IS NULL OR l.FannedOutModified < l.Modified)
      AND (l.FanOutErrorModified IS NULL OR l.FanOutErrorModified < l.Modified);

    -- Pending landing rows that didn't match a CAMP row (non-fatal): record them
    -- the same way as a CAMP rejection, so they're reported once and listed
    -- with the other rows needing a fix, instead of being re-counted and
    -- warned about on every run. Edited again in TAC, they're re-tried.
    UPDATE l
    SET FanOutError = 'No matching ObjectId in dbo.BiocontainmentObservation',
        FanOutErrorModified = l.Modified
    FROM TAC_src.BiocontainmentObservations l
    WHERE (l.FannedOutModified IS NULL OR l.FannedOutModified < l.Modified)
      AND (l.FanOutErrorModified IS NULL OR l.FanOutErrorModified < l.Modified)
      AND NOT EXISTS (SELECT 1 FROM @matched m WHERE m.landingObjectId = l.objectid);

    SELECT @rowError = @@ERROR, @unmatchedCount = @@ROWCOUNT;

    IF @rowError <> 0
    BEGIN
        SELECT @errno = 30025, @errmsg = 'Error occurred recording unmatched TAC_src.BiocontainmentObservations rows.';
        GOTO error;
    END;

    -- Rows with nothing to change: mark them fanned out without touching CAMP,
    -- so they don't generate a no-op update or editCommentBuffer audit row and
    -- aren't re-evaluated every run. Only mark rows whose CAMP rowversion is
    -- unchanged since the comparison; anything else stays pending and is
    -- re-compared next run.
    UPDATE l
    SET FannedOutModified = m.landingModified,
        FanOutError = NULL,
        FanOutErrorModified = NULL
    FROM TAC_src.BiocontainmentObservations l
        INNER JOIN @matched m ON m.landingTid = l.tid AND m.hasChanges = 0
        INNER JOIN dbo.BiocontainmentObservation b ON b.tid = m.targetTid AND b.timestamp = m.capturedTimestamp;

    SELECT @rowError = @@ERROR, @unchangedCount = @@ROWCOUNT;

    IF @rowError <> 0
    BEGIN
        SELECT @errno = 30024, @errmsg = 'Error occurred marking unchanged TAC_src.BiocontainmentObservations rows as fanned out.';
        GOTO error;
    END;

    -- Unchanged rows not marked above lost the rowversion race the same way
    -- as an update conflict below, so report them together.
    SELECT @conflictCount = COUNT(*) - @unchangedCount FROM @matched WHERE hasChanges = 0;

    DELETE FROM @matched WHERE hasChanges = 0;

    IF NOT EXISTS (SELECT 1 FROM @matched)
        GOTO done;


    -- One row per transaction, so a value CAMP rejects (CHECK/FK/NOT NULL/unique
    -- constraint, truncation, overflow) only skips that row instead of rolling
    -- back the whole run and blocking every later run behind it.
    SELECT @targetTid = MIN(targetTid) FROM @matched;

    WHILE @targetTid IS NOT NULL
    BEGIN
        SELECT @landingTid = landingTid FROM @matched WHERE targetTid = @targetTid;

        BEGIN TRY
            BEGIN TRANSACTION;

            -- CAMP's update trigger on dbo.BiocontainmentObservation reads the
            -- edit comment from editCommentBuffer, so the buffer row must exist
            -- before the UPDATE fires it. If the row then loses the rowversion
            -- check or is rejected, the ROLLBACK below / in CATCH removes this
            -- buffer row too, so no orphaned entry is left behind.
            --
            -- editComment is the only place CAMP's audit trail can show who made
            -- the edit, so it carries the TAC (LabKey) user's email.
            INSERT INTO dbo.editCommentBuffer (tableName, tid, editComment)
            SELECT 'BiocontainmentObservation', @targetTid,
                   'TAC ETL sync - edited by ' + COALESCE(l.ModifiedByEmail, 'unknown TAC user')
            FROM TAC_src.BiocontainmentObservations l
            WHERE l.tid = @landingTid;

            -- Optimistic concurrency: only apply if the row's rowversion still
            -- matches what we captured above. A row that was concurrently
            -- modified (e.g. by the Android app) between the match and here is
            -- left alone - transaction rolled back, FannedOutModified not set -
            -- so it stays eligible and is retried next run against CAMP's
            -- now-current data.
            UPDATE b
            SET Location             = COALESCE(m.Location, b.Location),
                -- Every other column is assigned directly. Which columns may be NULL depends on the
                -- form (a 4-point row has no weight loss; a 4-point Found Dead row has no scores;
                -- Cage Cleaning and Water are NULL for N/A), and the export sends the whole TAC row,
                -- so a NULL here is the TAC value. CAMP's CHECK constraints reject an incomplete row,
                -- and it lands in FanOutError.
                WeightLoss           = m.WeightLoss,
                WeightLoss_CO        = m.WeightLoss_CO,
                TemperatureChange    = m.TemperatureChange,
                TemperatureChange_CO = m.TemperatureChange_CO,
                Responsiveness       = m.Responsiveness,
                HairCoat             = m.HairCoat,
                Respiration          = m.Respiration,
                Petechia             = m.Petechia,
                Petechia_CO          = m.Petechia_CO,
                Bleeding             = m.Bleeding,
                NasalDischarge       = m.NasalDischarge,
                FeedEaten            = m.FeedEaten,
                FeedEaten_CO         = m.FeedEaten_CO,
                FoodEnrichment       = m.FoodEnrichment,
                FoodEnrichment_CO    = m.FoodEnrichment_CO,
                Stool                = m.Stool,
                FluidIntake          = m.FluidIntake,
                Dehydration          = m.Dehydration,
                Dehydration_CO       = m.Dehydration_CO,
                Dehydration_NS       = m.Dehydration_NS,
                FoundDead            = m.FoundDead,
                CageCleaning         = m.CageCleaning,
                Water                = m.Water,
                Comment              = m.Comment
            FROM dbo.BiocontainmentObservation b
                INNER JOIN @matched m ON m.targetTid = b.tid AND b.timestamp = m.capturedTimestamp
            WHERE b.tid = @targetTid;

            SET @rowsUpdated = @@ROWCOUNT;

            IF @rowsUpdated = 0
            BEGIN
                -- Lost the rowversion check: rolling back also discards the
                -- editCommentBuffer row inserted above.
                ROLLBACK TRANSACTION;
                SET @conflictCount = @conflictCount + 1;
            END
            ELSE
            BEGIN
                UPDATE l
                SET FannedOutModified = m.landingModified,
                    FanOutError = NULL,
                    FanOutErrorModified = NULL
                FROM TAC_src.BiocontainmentObservations l
                    INNER JOIN @matched m ON m.landingTid = l.tid
                WHERE l.tid = @landingTid;

                COMMIT TRANSACTION;
                SET @updatedCount = @updatedCount + 1;
            END;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            -- Data errors are this row's problem: record it and move on.
            -- Anything else (missing editCommentBuffer, a trigger error,
            -- deadlock, permissions) is a real failure and fails the run.
            IF ERROR_NUMBER() NOT IN (547,   -- CHECK / FOREIGN KEY constraint
                                      515,   -- NULL into a NOT NULL column
                                      2601,  -- duplicate key (unique index)
                                      2627,  -- duplicate key (unique constraint)
                                      2628,  -- string truncation
                                      8152,  -- string truncation (older compat levels)
                                      220,   -- arithmetic overflow
                                      8115)  -- arithmetic overflow converting type
            BEGIN
                THROW;
            END;

            UPDATE l
            SET FanOutError = ERROR_MESSAGE(),
                FanOutErrorModified = m.landingModified
            FROM TAC_src.BiocontainmentObservations l
                INNER JOIN @matched m ON m.landingTid = l.tid
            WHERE l.tid = @landingTid;

            SET @rejectedCount = @rejectedCount + 1;
        END CATCH;

        SELECT @targetTid = MIN(targetTid) FROM @matched WHERE targetTid > @targetTid;
    END;

    done:
    SELECT @updatedCount   AS UpdatedCount,
           @unchangedCount AS UnchangedCount,
           @unmatchedCount AS UnmatchedCount,
           @conflictCount  AS ConflictCount,
           @rejectedCount  AS RejectedCount;
    RETURN;

    error:
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    RAISERROR('%d: %s', 16, 0, @errno, @errmsg);
END
GO


GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.BiocontainmentObservations TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.BiocontainmentObservations TO z_labkey;
GRANT EXECUTE ON [TAC_src].[usp_FanOutBiocontainmentObservations] TO z_labkey;
GO