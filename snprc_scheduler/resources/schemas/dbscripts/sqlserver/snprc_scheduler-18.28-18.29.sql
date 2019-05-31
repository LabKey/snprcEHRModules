/***************************************
Integrity triggers


  srr 05.28.2019
 **************************************/

/*****************************  snprc_scheduler.tia_StudyDayNotes  *****************************************/

if exists (select 1
from sysobjects
where id = object_id('snprc_scheduler.tiu_StudyDayNotes')
and type = 'TR')
drop trigger snprc_scheduler.tiu_StudyDayNotes
    go


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
CREATE TRIGGER snprc_scheduler.tiu_StudyDayNotes ON snprc_scheduler.StudyDayNotes FOR INSERT, UPDATE AS
BEGIN
DECLARE
@numrows  INT,
    @numnull  INT,
    @errno    INT,
    @errmsg   VARCHAR(255)

SELECT   @numrows = @@rowcount
             IF @numrows = 0
RETURN
IF	UPDATE(TimelineObjectId) OR
UPDATE(StudyDay)
BEGIN
IF (SELECT COUNT(*)
FROM   SNPRC_Scheduler.Timelineitem  t
INNER JOIN INSERTED i
ON  i.StudyDay = t.StudyDay AND i.TimelineObjectId = t.TimelineObjectId
) < 1
    BEGIN
SELECT @ERRNO  = 50001,
       @ERRMSG = ' StudyDayNotes Trigger - TimelineObjectId - StudyDay pair do not exist SNPRC_Scheduler.Timelineitem. Cannot insert to SNPRC_Scheduler.StudyDayNotes'
           GOTO ERROR
END
END

-- Return if all is well
    RETURN

/* Error handling */
error:
    RAISERROR( '%d: %s', 16, 0, @errno, @errmsg)
-- LK will handle ROLLBACK  TRANSACTION
END
    GO

ALTER TABLE snprc_scheduler.StudyDayNotes
    ENABLE TRIGGER tiu_StudyDayNotes



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



/*
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
*/


/*	For referential integrity only.
	Sole purpose is to prevent orphaning a StudyDayNote entry if all applicable TimeLineItems are deleted
	For DELETE
   srr 05.28.19
 */
CREATE TRIGGER snprc_scheduler.td_TimelineItem
    ON snprc_scheduler.TimelineItem
    FOR DELETE
            AS
BEGIN
DECLARE @numrows INT,
            @numnull INT,
            @errno INT,
		    @errmsg VARCHAR(255);

SELECT @numrows = @@rowcount;
IF @numrows = 0
        RETURN;
    BEGIN

IF
(
    SELECT COUNT(*)  -- TimelineItem rows for StudyDay-TimelineObjectID
    FROM snprc_scheduler.TimelineItem tli
    WHERE EXISTS (SELECT 1 FROM Deleted d WHERE d.ProjectitemId = tli.ProjectitemId)
) > @numrows
BEGIN
SELECT @errno = 50001,
       @errmsg
           = ' Timeline Item Trigger - TimelineItem has a StudyDayNote.  Note must be deleted first.  Data not modified.';
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

ALTER TABLE snprc_scheduler.TimelineItem  ENABLE TRIGGER td_TimelineItem;

/******************************************/
-- setting ProjectItemID to NOT NULL


ALTER TABLE snprc_scheduler.TimelineItem
    ALTER COLUMN  ProjectitemId INT  NULL

--srr 05.29.19
/*****************************************/