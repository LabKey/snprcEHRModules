/*******************************************
Add RC to Timeline table
srr 01.08.2019
*******************************************/
ALTER TABLE snprc_scheduler.Timeline ADD
  RC nvarchar(50) NULL
GO