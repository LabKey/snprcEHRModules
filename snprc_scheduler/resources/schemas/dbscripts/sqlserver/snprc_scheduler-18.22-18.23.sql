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



ALTER TABLE [snprc_scheduler].[TimelineItem] DROP CONSTRAINT [FK_TimelineItem_Timeline]
GO

ALTER TABLE [snprc_scheduler].[TimelineItem] DROP CONSTRAINT [FK_TimelineItem_SNDProjectItem]
GO

ALTER TABLE [snprc_scheduler].[Schedule] DROP CONSTRAINT [FK_ScheduleFK1]
GO


/****** Object:  Table [snprc_scheduler].[TimelineItem]    Script Date: 11/12/2018 11:42:24 AM ******/
DROP TABLE [snprc_scheduler].[TimelineItem]
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
