-- Create schema, tables, indexes, and constraints used for Snprc_scheduler module here
-- All SQL VIEW definitions should be created in snprc_scheduler-create.sql and dropped in snprc_scheduler-drop.sql
CREATE SCHEMA snprc_scheduler;
GO

/************************************************************************
Create schema
Timeline,
TimelineItem,
Schedule,
TimelineAnimalJunction,
TimelinePojectItem


Do not have date bound reference from Timeline to TimelineAnimalJunction
Do not have date bound reference TimelineAnimalJunction to studyDataset_..._assignments


srr 10.30.18

Added qc and revisionNum columns
srr 11.01.2018

refactor keys, qcstate only in timeline.
pulled container from all tables

Changed FK to snd.Projects back to composite.
Dropped ProjectObjectId from Timeline table.
srr 11.07.2018

************************************************************************/



/*==============================================================*/
/* Table: Timeline                                              */
/*==============================================================*/
create table SNPRC_Scheduler.Timeline (
  TimelineId           int                  not null,
  RevisionNum          int                  not null,
  ProjectObjectId      entityId             not null,
  StartDate            date                 null,
  EndDate              date                 null,
  Description          nvarchar(255)        null,
  LeadTech             nvarchar(50)         null,
  Notes                nvarchar(Max)        null,
  SchedulerNotes       nvarchar(500)        null,
  QcState              int                  null,
  Created              datetime             null,
  CreatedBy            int                  null,
  Modified             datetime             null,
  ModifiedBy           int                  null,
  ObjectId             entityId             not null
)
go
execute sp_addextendedproperty 'MS_Description',
                               'Data Dict',
                               'Schema', 'SNPRC_Scheduler', 'table', 'timeline'
go

execute sp_addextendedproperty 'MS_Description',
                               'Added during 9/17/18 meeting. Size TBD',
                               'Schema', 'SNPRC_Scheduler', 'table', 'timeline', 'column', 'Notes'
go

execute sp_addextendedproperty 'MS_Description',
                               'Will handle isActive function',
                               'Schema', 'SNPRC_Scheduler', 'table', 'timeline', 'column', 'qcstate'
go


alter table SNPRC_Scheduler.Timeline
  add constraint PK_Timeline primary key nonclustered (TimelineId, RevisionNum)
go

alter table SNPRC_Scheduler.Timeline
  add constraint AK_TimelineObjectId unique (ObjectId)
go



/*==============================================================*/
/* Index: IDX_TimelineFK1                                       */
/*==============================================================*/
create clustered index IDX_TimelineFK1 on SNPRC_Scheduler.Timeline (
  ProjectObjectId ASC
);
go

alter table SNPRC_Scheduler.Timeline
  add constraint FK_Timeline_SNDProject foreign key (ProjectObjectId)
references snd.projects (Objectid);
go





-- %%  111111111111  %%%%%  end timeline


/*==============================================================*/
/* Table: TimelineItem       2                                   */
/*==============================================================*/
create table SNPRC_Scheduler.TimelineItem (
  TimelineItemId       int                  identity,
  ProjectitemId        int                  not null,
  TimelineObjectId     entityId             not null,
  StudyDay             int                  null,
  ScheduleDay          int                  null,
  Created              datetime             null,
  CreatedBy            int                  null,
  Modified             datetime             null,
  ModifiedBy           int                  null,
  ObjectId             entityId             not null
)

go
alter table SNPRC_Scheduler.TimelineItem
  add constraint PK_TimelineItem primary key nonclustered (TimelineItemId);

go

alter table SNPRC_Scheduler.TimelineItem
  add constraint AK_TimelineItemObjectId unique (ObjectId);
go


/*==============================================================*/
/* Index: IDXC_TimelineItemFK2                                  */
/*==============================================================*/
create clustered index IDXC_TimelineItemFK2 on SNPRC_Scheduler.TimelineItem (
  ProjectItemId ASC
);

/*==============================================================*/
/* Index: IDX_TimelineItemFK1                                   */
/*==============================================================*/
create index IDX_TimelineItemFK1 on SNPRC_Scheduler.TimelineItem (
  TimelineObjectId ASC
);
go

alter table SNPRC_Scheduler.Timelineitem
  add constraint FK_TimelineItem_Timeline foreign key (TimelineObjectId)
references SNPRC_Scheduler.Timeline (ObjectId);
go
alter table SNPRC_Scheduler.Timelineitem
  add constraint FK_TimelineItem_SNDProjectItem foreign key (ProjectItemId)
references snd.ProjectItems (ProjectItemId);
go
-- %% 22222222222 %%  end timelineItem

/*==============================================================*/
/* Table: Schedule  3                                            */
/*==============================================================*/
create table SNPRC_Scheduler.Schedule (
  ScheduleId           int                  identity,
  TimelineItemId       int                  not null,
  TargetDate           datetime             not null,
  Created              datetime             null,
  CreatedBy            int                  null,
  Modified             datetime             null,
  ModifiedBy           int                  null,
  ObjectId             EntityId             not null
);

go

alter table SNPRC_Scheduler.Schedule
  add constraint PK_Schedule primary key (ScheduleId);
go


/*==============================================================*/
/* Index: IDX_ScheduleFK1                                       */
/*==============================================================*/
create index IDX_ScheduleFK1 on SNPRC_Scheduler.Schedule (
  TimelineItemId ASC
)


alter table SNPRC_Scheduler.Schedule
  add constraint FK_ScheduleFK1 foreign key (TimelineItemId)
references SNPRC_Scheduler.TimelineItem (TimelineItemId)
go


-- %%% 333333 %%%  end Schedule

/*==============================================================*/
/* Table: TimelineProjectItem   4                                   */
/*==============================================================*/
create table SNPRC_Scheduler.TimelineProjectItem (
  ProjectItemId        int                  not null,
  TimelineObjectId     entityId             not null,
  TimelineId           int                  not null,
  TimelineRevisionNum  int                  not null,
  TimelineFootNotes    nvarchar(100)        null,
  SortOrder            int                  not null
)
go

alter table SNPRC_Scheduler.TimelineProjectItem
  add constraint PK_TimelineProjectItem primary key (TimelineObjectId, ProjectItemId)
go

/*==============================================================*/
/* Index: IDX_TimelineProjectItemFK1                            */
/*==============================================================*/
create index IDX_TimelineProjectItemFK1 on SNPRC_Scheduler.TimelineProjectItem (
  TimelineObjectid ASC
)
go

/*==============================================================*/
/* Index: IDX_TimelineItemFK2                                   */
/*==============================================================*/
create index IDX_TimelineProjectItemFK2 on SNPRC_Scheduler.TimelineProjectItem (
  ProjectItemId ASC
)
go

alter table SNPRC_Scheduler.TimelineProjectItem
  add constraint FK_TimelineProjectItem_SndProject foreign key (ProjectItemId)
references snd.ProjectItems (ProjectitemId)
go

alter table SNPRC_Scheduler.TimelineProjectItem
  add constraint FK_TimelineProjectItem foreign key (TimelineObjectId)
references SNPRC_Scheduler.Timeline (ObjectId)
go



-- %%%%%%%   4444444 %%%%%%%%%%%% end TimelineProjectItem

/*==============================================================*/
/* Table: timelineanimaljunction  5                              */
/*==============================================================*/
create table SNPRC_Scheduler.TimelineAnimalJunction (
  RowId                int                  identity,
  AnimalId             nvarchar(50)         not null,
  TimelineObjectId     entityId             null,
  StartDate            date                 null,
  StopDate             date                 null,
  Created              datetime             null,
  CreatedBy            int                  null,
  Modified             datetime             null,
  ModifiedBy           int                  null,
  ObjectId             entityId             not null
)

go

alter table SNPRC_Scheduler.TimelineAnimalJunction
  add constraint PK_TimelineAnimalJunction primary key nonclustered (RowId)
go


/*==============================================================*/
/* Index: IDXC_TimelineAnimalJunctionFK1                        */
/*==============================================================*/
create clustered index IDXC_TimelineAnimalJunctionFK1 on SNPRC_Scheduler.TimelineAnimalJunction (
  TimelineObjectId ASC
)
go

/*==============================================================*/
/* Index: IDX_TimelineAnimalJunctionFK2                         */
/*==============================================================*/
create index IDX_TimelineAnimalJunctionFK2 on SNPRC_Scheduler.TimelineAnimalJunction (
  AnimalID ASC
)
go


alter table SNPRC_Scheduler.TimelineAnimalJunction
  add constraint FK_TimelineJunction_Timeline foreign key (TimelineObjectId)
references SNPRC_Scheduler.Timeline (ObjectId)
go

/******************************************************

   rename snprc_scheduler.TimelineAnimalJunction.StopDate to EndDate

srr 11.12.2018
******************************************************/
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON

GO
EXECUTE sp_rename N'snprc_scheduler.TimelineAnimalJunction.StopDate', N'Tmp_EndDate', 'COLUMN'
GO
EXECUTE sp_rename N'snprc_scheduler.TimelineAnimalJunction.Tmp_EndDate', N'EndDate', 'COLUMN'
GO
ALTER TABLE snprc_scheduler.TimelineAnimalJunction
  DROP COLUMN StartDate
GO
--  END   rename StopDate  to EndDate



/*#######################################################################
Change column:
 ScheduleDay int
to
 ScheduleDate date





srr. 11.12.18
#######################################################################    */



ALTER TABLE [snprc_scheduler].[TimelineItem] DROP CONSTRAINT [FK_TimelineItem_Timeline];
GO

ALTER TABLE [snprc_scheduler].[TimelineItem] DROP CONSTRAINT [FK_TimelineItem_SNDProjectItem];
GO

ALTER TABLE [snprc_scheduler].[Schedule] DROP CONSTRAINT [FK_ScheduleFK1];
GO


/****** Object:  Table [snprc_scheduler].[TimelineItem]    Script Date: 11/12/2018 11:42:24 AM ******/
DROP TABLE [snprc_scheduler].[TimelineItem];
GO

/****** Object:  Table [snprc_scheduler].[TimelineItem]    Script Date: 11/12/2018 11:42:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/**/
/*==============================================================*/
/* Table: TimelineItem       2                                   */
/*==============================================================*/
create table SNPRC_Scheduler.TimelineItem (
  TimelineItemId       int                  identity,
  ProjectitemId        int                  not null,
  TimelineObjectId     entityId             not null,
  StudyDay             int                  null,
  ScheduleDate         datetime             null,
  Created              datetime             null,
  CreatedBy            int                  null,
  Modified             datetime             null,
  ModifiedBy           int                  null,
  ObjectId             entityId             not null
)

  go
alter table SNPRC_Scheduler.TimelineItem
  add constraint PK_TimelineItem primary key nonclustered (TimelineItemId)

go

alter table SNPRC_Scheduler.TimelineItem
  add constraint AK_TimelineItemObjectId unique (ObjectId)
go


/*==============================================================*/
/* Index: IDXC_TimelineItemFK2                                  */
/*==============================================================*/
create clustered index IDXC_TimelineItemFK2 on SNPRC_Scheduler.TimelineItem (
ProjectItemId ASC
)

/*==============================================================*/
/* Index: IDX_TimelineItemFK1                                   */
/*==============================================================*/
create index IDX_TimelineItemFK1 on SNPRC_Scheduler.TimelineItem (
  TimelineObjectId ASC
)
  go

alter table SNPRC_Scheduler.Timelineitem
  add constraint FK_TimelineItem_Timeline foreign key (TimelineObjectId)
references SNPRC_Scheduler.Timeline (ObjectId)
go
alter table SNPRC_Scheduler.Timelineitem
  add constraint FK_TimelineItem_SNDProjectItem foreign key (ProjectItemId)
references snd.ProjectItems (ProjectItemId)
go

alter table SNPRC_Scheduler.Schedule
  add constraint FK_ScheduleFK1 foreign key (TimelineItemId)
references SNPRC_Scheduler.TimelineItem (TimelineItemId)
go

/***********************************************
Adding Created,Modified and ObjectId

Populate ObjectId for current data,
set to NOT NULL


srr 11.28.2018
srr 12.05.2018  Removed SETs
***********************************************/
--BEGIN TRANSACTION
/*
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
*/
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

/***********************************************
Table snprc_Scheduler.Schedule was refactored out
Dropping the table and FK


srr 11.30.2018
***********************************************/
ALTER TABLE [snprc_scheduler].[Schedule] DROP CONSTRAINT [FK_ScheduleFK1]
GO

/****** Object:  Table [snprc_scheduler].[Schedule]    Script Date: 11/29/2018 11:16:22 AM ******/
DROP TABLE [snprc_scheduler].[Schedule]
GO

/*******************************************
TimelineObjectId should be NOT NULL
srr 12.04.2018
*******************************************/
DROP INDEX [IDXC_TimelineAnimalJunctionFK1] ON [snprc_scheduler].[TimelineAnimalJunction] WITH ( ONLINE = OFF )
GO
-- set TimelineObjectId to NOT NULL
ALTER TABLE snprc_scheduler.TimelineAnimalJunction
  ALTER COLUMN TimelineObjectId ENTITYID NOT NULL


CREATE CLUSTERED INDEX [IDXC_TimelineAnimalJunctionFK1] ON [snprc_scheduler].[TimelineAnimalJunction]
(
[TimelineObjectId] ASC
)
GO

/*******************************************
Add RC to Timeline table
srr 01.08.2019
*******************************************/
ALTER TABLE snprc_scheduler.Timeline ADD
  RC nvarchar(50) NULL
GO

/*******************************************
Add AnimalAccount to Timeline table
Will hold a concated list of animal acccount
for this project.
NOTE: Reference only, not validated
srr 05.22.2019
*******************************************/
ALTER TABLE snprc_scheduler.Timeline
    ADD AnimalAccount NVARCHAR(255) NULL;
GO
/******************************************
Add alternate key to TimlelineItem
for reference to the new StudyDayNotes table
srr 05.22.2019
*******************************************/

-- Reference is not to unique row
-- will handle integrity via a different mechanism
-- srr 05.28.2019

/*
ALTER TABLE snprc_scheduler.TimelineItem
    ADD CONSTRAINT AK_AK_STUDYDAYNOTES_TIMELINE
        UNIQUE (
                TimelineObjectId,
                StudyDay
            );
GO
*/
-- drop table if it exists
EXEC core.fn_dropifexists 'StudyDayNotes','snprc_scheduler', 'TABLE';


/********************************************
Create table to hold day specific study notes.

C:\MySoftware\labkey\trunk\externalModules\snprcEHRModules
snprcEHRModules
srr 05.22.2019
*********************************************/
/*==============================================================*/
/* Table: StudyDayNotes                                         */
/*==============================================================*/
CREATE TABLE snprc_scheduler.StudyDayNotes
(
    ObjectId ENTITYID NOT NULL,
    TimelineObjectId UNIQUEIDENTIFIER NULL,
    StudyDay INT NULL,
    StudyDayNote NVARCHAR(MAX) NULL,
    QcState INT NULL,
    Created DATETIME NULL,
    CreatedBy INT NULL,
    Modified DATETIME NULL,
    ModifiedBy INT NULL
);
GO

ALTER TABLE snprc_scheduler.StudyDayNotes
    ADD CONSTRAINT PK_STUDYDAYNOTES
        PRIMARY KEY (ObjectId);
GO

-- Reference is not to unique row
-- will handle integrity via a different mechanism
-- srr 05.24.2019
/*
ALTER TABLE snprc_scheduler.StudyDayNotes
    ADD CONSTRAINT FK_STUDYDAY_FK_TIMELI_TIMELINE
        FOREIGN KEY (
                     TimelineObjectId,
                     StudyDay
            )
            REFERENCES snprc_scheduler.TimelineItem (
                                                     TimelineObjectId,
                                                     StudyDay
                );
*/

/***************************************
Integrity triggers


  srr 05.28.2019
 **************************************/

/*****************************  snprc_scheduler.tia_StudyDayNotes  *****************************************/

/****** Object:  Trigger [snprc_scheduler].[tia_StudyDayNotes]    Script Date: 5/28/2019 10:50:47 AM ******/


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
GO

/*****************************  snprc_scheduler.td_TimelineItem  *****************************************/

CREATE TRIGGER [SNPRC_Scheduler].[td_TimelineItem]
    ON [SNPRC_Scheduler].[TimelineItem]
    FOR DELETE
            AS
BEGIN
/*****************************************************
 StudyDayNotes was an late addition to model.
This trigger’s sole purpose is to enforce referential integrity
  between TimelineItem and StudyDayNotes tables
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
-- No note rows for deleted items therefore nothing to do, exit
IF (SELECT COUNT(*)
    FROM Deleted d
             INNER JOIN SNPRC_Scheduler.StudyDayNotes n
                        ON n.StudyDay = d.StudyDay AND n.TimelineObjectId = d.TimelineObjectId) = 0
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

/******************************
Added unique index to FK columns
  to ensure no duplicate rows.

srr 06.10.2019
******************************/

/****** Object:  Index [idx_u_FK_TimelineItem]    Script Date: 6/10/2019 4:00:27 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX idx_u_FK_to_TimelineItem ON snprc_scheduler.StudyDayNotes
(
	TimelineObjectId ASC,
	StudyDay ASC
)
GO

ALTER TABLE snprc_scheduler.StudyDayNotes
    DROP COLUMN QcState
GO