/***********************************************
Adding Created,Modified and ObjectId

Populate ObjectId for current data,
set to NOT NULL


srr 11.28.2018
***********************************************/
--BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
--COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE snprc_scheduler.TimelineProjectItem ADD
  Created datetime NULL,
CreatedBy int NULL,
Modified datetime NULL,
ModifiedBy int NULL,
ObjectId dbo.ENTITYID NULL
GO
UPDATE snprc_scheduler.TimelineProjectItem
SET ObjectID = NEWID()
WHERE ObjectID IS null
    GO
ALTER TABLE snprc_scheduler.TimelineProjectItem
  DROP COLUMN TimelineId, TimelineRevisionNum
GO
ALTER TABLE snprc_scheduler.TimelineProjectItem
  ALTER COLUMN ObjectId  dbo.ENTITYID NOT NULL


ALTER TABLE snprc_scheduler.TimelineProjectItem SET (LOCK_ESCALATION = TABLE)
GO
if @@trancount = 1
COMMIT
--select 'All is well'