/******************************
Added unique index to FK columns
  to ensure no duplicate rows.

srr 06.10.2019
******************************/

-- delete index if it exists
if exists (select 1
            from  sysindexes
           where  id    = object_id('snprc_scheduler.StudyDayNotes')
            and   name  = 'idx_u_FK_to_TimelineItem'

            and   indid > 0
            and   indid < 255)
drop index idx_u_FK_to_TimelineItem  ON snprc_scheduler.StudyDayNotes

go



/****** Object:  Index [idx_u_FK_TimelineItem]    Script Date: 6/10/2019 4:00:27 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX idx_u_FK_to_TimelineItem ON snprc_scheduler.StudyDayNotes
(
	TimelineObjectId ASC,
	StudyDay ASC
)
GO
