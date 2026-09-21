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
    FannedOutDate DATETIME NULL,
    CONSTRAINT PK_TAC_BIOCONTAINMENTOBSERVATIONS
        PRIMARY KEY CLUSTERED (tid ASC)
)
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
-- ==========================================================================================
BEGIN
    SET NOCOUNT ON;

    DECLARE @errno  INT,
            @errmsg VARCHAR(255);

    DECLARE @matched TABLE
    (
        targetTid          INT NOT NULL PRIMARY KEY,
        landingTid          INT NOT NULL,
        landingObjectId     UNIQUEIDENTIFIER NOT NULL,
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
        Comment             VARCHAR(80) NULL
    );

    -- capturedTimestamp is CAMP's rowversion for this row at match time. The
    -- final UPDATE below only applies if the row's rowversion is still this
    -- value, so a concurrent edit to the same CAMP row (e.g. from the Android
    -- app) between this SELECT and the UPDATE loses the race safely instead
    -- of being silently overwritten - the loser is left unmatched, its
    -- FannedOutDate stays NULL, and it's picked up again on the next run.
    INSERT INTO @matched
    SELECT b.tid, l.tid, l.objectid, b.timestamp, l.Location, l.WeightLoss, l.WeightLoss_CO,
           l.TemperatureChange, l.TemperatureChange_CO, l.Responsiveness,
           l.HairCoat, l.Respiration, l.Petechia, l.Petechia_CO, l.Bleeding,
           l.NasalDischarge, l.FeedEaten, l.FeedEaten_CO, l.FoodEnrichment,
           l.FoodEnrichment_CO, l.Stool, l.FluidIntake, l.Dehydration,
           l.Dehydration_CO, l.Comment
    FROM TAC_src.BiocontainmentObservations l
        INNER JOIN dbo.BiocontainmentObservation b ON b.ObjectId = l.objectid
    WHERE l.FannedOutDate IS NULL OR l.FannedOutDate < l.Modified;

    -- Log (non-fatal) any not-yet-fanned-out landing rows that didn't match
    -- a CAMP row.
    IF EXISTS (SELECT 1 FROM TAC_src.BiocontainmentObservations l
               WHERE (l.FannedOutDate IS NULL OR l.FannedOutDate < l.Modified)
                 AND NOT EXISTS (SELECT 1 FROM @matched m WHERE m.landingObjectId = l.objectid))
    BEGIN
        DECLARE @unmatchedCount INT =
        (
            SELECT COUNT(*) FROM TAC_src.BiocontainmentObservations l
            WHERE (l.FannedOutDate IS NULL OR l.FannedOutDate < l.Modified)
              AND NOT EXISTS (SELECT 1 FROM @matched m WHERE m.landingObjectId = l.objectid)
        );
        RAISERROR('TAC_src.usp_FanOutBiocontainmentObservations: %d row(s) had no matching ObjectId in dbo.BiocontainmentObservation and were skipped', 10, 1, @unmatchedCount) WITH NOWAIT;
    END;

    IF NOT EXISTS (SELECT 1 FROM @matched)
        RETURN;


    DECLARE @updated TABLE (targetTid INT NOT NULL PRIMARY KEY, landingTid INT NOT NULL);

    BEGIN TRANSACTION;

    -- Optimistic concurrency: only apply to rows whose rowversion still
    -- matches what we captured above. A row that was concurrently modified
    -- (e.g. by the Android app) between the match and here is silently
    -- excluded from the OUTPUT, so it gets neither an editCommentBuffer
    -- entry nor its FannedOutDate set - it stays eligible and is retried
    -- on the next run against CAMP's now-current data.
    UPDATE b
    SET Location             = COALESCE(m.Location, b.Location),
        WeightLoss           = COALESCE(m.WeightLoss, b.WeightLoss),
        WeightLoss_CO        = COALESCE(m.WeightLoss_CO, b.WeightLoss_CO),
        TemperatureChange    = COALESCE(m.TemperatureChange, b.TemperatureChange),
        TemperatureChange_CO = COALESCE(m.TemperatureChange_CO, b.TemperatureChange_CO),
        Responsiveness       = COALESCE(m.Responsiveness, b.Responsiveness),
        HairCoat             = COALESCE(m.HairCoat, b.HairCoat),
        Respiration          = COALESCE(m.Respiration, b.Respiration),
        Petechia             = COALESCE(m.Petechia, b.Petechia),
        Petechia_CO          = COALESCE(m.Petechia_CO, b.Petechia_CO),
        Bleeding             = COALESCE(m.Bleeding, b.Bleeding),
        NasalDischarge       = COALESCE(m.NasalDischarge, b.NasalDischarge),
        FeedEaten            = COALESCE(m.FeedEaten, b.FeedEaten),
        FeedEaten_CO         = COALESCE(m.FeedEaten_CO, b.FeedEaten_CO),
        FoodEnrichment       = COALESCE(m.FoodEnrichment, b.FoodEnrichment),
        FoodEnrichment_CO    = COALESCE(m.FoodEnrichment_CO, b.FoodEnrichment_CO),
        Stool                = COALESCE(m.Stool, b.Stool),
        FluidIntake          = COALESCE(m.FluidIntake, b.FluidIntake),
        Dehydration          = COALESCE(m.Dehydration, b.Dehydration),
        Dehydration_CO       = COALESCE(m.Dehydration_CO, b.Dehydration_CO),
        Comment              = COALESCE(m.Comment, b.Comment)
    OUTPUT inserted.tid, m.landingTid INTO @updated (targetTid, landingTid)
    FROM dbo.BiocontainmentObservation b
        INNER JOIN @matched m ON m.targetTid = b.tid AND b.timestamp = m.capturedTimestamp;

    IF @@ERROR <> 0
    BEGIN
        SELECT @errno = 30021, @errmsg = 'Error occurred fanning TAC_src.BiocontainmentObservations edits out into dbo.BiocontainmentObservation.';
        GOTO error;
    END;

    IF EXISTS (SELECT 1 FROM @matched m WHERE NOT EXISTS (SELECT 1 FROM @updated u WHERE u.targetTid = m.targetTid))
    BEGIN
        DECLARE @conflictCount INT = (SELECT COUNT(*) FROM @matched m WHERE NOT EXISTS (SELECT 1 FROM @updated u WHERE u.targetTid = m.targetTid));
        RAISERROR('TAC_src.usp_FanOutBiocontainmentObservations: %d row(s) skipped due to a concurrent CAMP-side modification (rowversion mismatch); will retry next run', 10, 1, @conflictCount) WITH NOWAIT;
    END;

    IF NOT EXISTS (SELECT 1 FROM @updated)
    BEGIN
        COMMIT TRANSACTION;
        RETURN;
    END;

    INSERT INTO dbo.editCommentBuffer (tableName, tid, editComment)
    SELECT 'BiocontainmentObservation', targetTid, 'TAC ETL sync'
    FROM @updated;

    IF @@ERROR <> 0
    BEGIN
        SELECT @errno = 30022, @errmsg = 'Error occurred inserting into dbo.editCommentBuffer.';
        GOTO error;
    END;

    UPDATE l
    SET FannedOutDate = GETDATE()
    FROM TAC_src.BiocontainmentObservations l
        INNER JOIN @updated u ON u.landingTid = l.tid;

    IF @@ERROR <> 0
    BEGIN
        SELECT @errno = 30023, @errmsg = 'Error occurred marking TAC_src.BiocontainmentObservations rows as fanned out.';
        GOTO error;
    END;

    COMMIT TRANSACTION;
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