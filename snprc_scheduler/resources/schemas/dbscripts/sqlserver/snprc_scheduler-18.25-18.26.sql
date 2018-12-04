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