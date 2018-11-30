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