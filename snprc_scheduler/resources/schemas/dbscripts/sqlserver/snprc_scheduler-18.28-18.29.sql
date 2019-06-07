/***************************************
Integrity triggers


  srr 05.28.2019
 **************************************/

/*****************************  snprc_scheduler.tia_StudyDayNotes  *****************************************/

IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE id = OBJECT_ID('snprc_scheduler.tiu_StudyDayNotes')
          AND type = 'TR'
)
DROP TRIGGER snprc_scheduler.tiu_StudyDayNotes;
GO


/****** Object:  Trigger [snprc_scheduler].[tia_StudyDayNotes]    Script Date: 5/28/2019 10:50:47 AM ******/
/*
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
*/


/*	For referential integrity only.
	Sole purpose is to prevent a note entry for (timeline-study day) that does not exists.
	For INSERT and UPDATE
 */
CREATE TRIGGER snprc_scheduler.tiu_StudyDayNotes
    ON snprc_scheduler.StudyDayNotes
    FOR INSERT, UPDATE
    AS
BEGIN
DECLARE @numrows INT,
            @numnull INT,
            @errno INT,
            @errmsg VARCHAR(255);

SELECT @numrows = @@rowcount;
IF @numrows = 0
        RETURN;
IF UPDATE(TimelineObjectId)
       OR UPDATE(StudyDay)
BEGIN
IF
(
    SELECT COUNT(*)
    FROM snprc_scheduler.TimelineItem t
             INNER JOIN INSERTED i
                        ON i.StudyDay = t.StudyDay
                            AND i.TimelineObjectId = t.TimelineObjectId
) < 1
BEGIN
SELECT @errno = 50001,
       @errmsg
           = ' StudyDayNotes Trigger - TimelineObjectId - StudyDay pair do not exist SNPRC_Scheduler.Timelineitem. Cannot insert to SNPRC_Scheduler.StudyDayNotes';
GOTO ERROR;
END;
END;

-- Return if all is well
RETURN;

    /* Error handling */
error:
    RAISERROR('%d: %s', 16, 0, @errno, @errmsg);
-- LK will handle ROLLBACK  TRANSACTION
END;
GO

ALTER TABLE snprc_scheduler.StudyDayNotes ENABLE TRIGGER tiu_StudyDayNotes;



/*****************************  snprc_scheduler.td_TimelineItem  *****************************************/


IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE id = OBJECT_ID('snprc_scheduler.td_TimelineItem')
          AND type = 'TR'
)
DROP TRIGGER snprc_scheduler.td_TimelineItem;
GO


CREATE TRIGGER [SNPRC_Scheduler].[td_TimelineItem]
    ON [SNPRC_Scheduler].[TimelineItem]
    FOR DELETE
            AS
BEGIN
/*****************************************************
 StudyDayNotes was an late addition to model.
Each study day note requires one or more rows in the TimelineItem table.
This trigger used two table variables:
@Table_Notes holds rows that re required to have a matching row in the parent table.
@resultant uses EXCEPT operator to generate what the result of the delete will look like.
srr 06.07.19
 ****************************************************/
DECLARE @numrows INT,
            @numnull INT,
            @errno INT,
            @errmsg VARCHAR(255);

-- No rows, nothing to do
SELECT @numrows = @@rowcount;
IF @numrows = 0
        RETURN;

DECLARE @beforeCnt INT,
		@afterCnt INT
-- table var to hold join columns
DECLARE @tbl_Notes TABLE(
		StudyDay INT,
		TimelineObjecId UNIQUEIDENTIFIER
		)
-- table var to hold resultant table
DECLARE @resultant TABLE(
		StudyDay INT,
		TimelineObjecId UNIQUEIDENTIFIER,
		ProjectitemId int
		)

	-- these must exist in the post delete TimelineItem table
INSERT INTO @tbl_Notes(StudyDay, TimelineObjecId)
SELECT DISTINCT StudyDay, TimelineObjectId
FROM Deleted
    -- EXCEPT  used to generate the resultant table
    INSERT INTO @resultant
   (
    StudyDay,
    TimelineObjecId,
    ProjectitemId
    )
SELECT r.StudyDay, r.TimelineObjectId, r.ProjectitemId
FROM (-- new resultant table
         SELECT b.TimelineItemId, b.ProjectitemId, b.TimelineObjectId, b.StudyDay
         FROM SNPRC_Scheduler.TimelineItem b
                  INNER JOIN @tbl_Notes n
         ON n.StudyDay = b.StudyDay AND n.TimelineObjecId = b.TimelineObjectId
             EXCEPT
         SELECT d.TimelineItemId, d.ProjectitemId, d.TimelineObjectId, d.StudyDay
         FROM Deleted d
             INNER JOIN @tbl_Notes n
         ON n.StudyDay = d.StudyDay AND n.TimelineObjecId = d.TimelineObjectId
     ) r


    IF(	SELECT COUNT(*)
                  --SELECT n.StudyDay, n.TimelineObjecId, r.StudyDay, r.TimelineObjecId
           FROM @tbl_Notes n
               LEFT OUTER JOIN @resultant r
           ON r.StudyDay = n.StudyDay AND r.TimelineObjecId = n.TimelineObjecId
           WHERE r.StudyDay IS NULL OR r.TimelineObjecId IS null) > 0
BEGIN
SELECT @errno = 50001,
       @errmsg
           = ' Timeline Item Trigger - TimelineItem has a StudyDayNote and only item on Study day.  Note must be deleted first.  Data not modified.';
GOTO ERROR;

END;


-- Return if all is well
RETURN;

    /* Error handling */
error:
    RAISERROR('%d: %s', 16, 0, @errno, @errmsg);
-- LK will handle ROLLBACK  TRANSACTION
END;
GO
ALTER TABLE snprc_scheduler.TimelineItem ENABLE TRIGGER td_TimelineItem;

/******************************************/
-- setting ProjectItemID to NOT NULL


ALTER TABLE snprc_scheduler.TimelineItem
    ALTER COLUMN ProjectitemId INT NULL;

--srr 05.29.19
/*****************************************/