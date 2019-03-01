EXEC core.fn_dropifexists 'LocationTemperature','snprc_ehr', 'TABLE';

GO
/*************************************
ObjectId should be populated before insert.


srr 02.25.2019
*************************************/

CREATE TABLE [snprc_ehr].[LocationTemperature](
  [Room] [varchar](100) NOT NULL,
  [Date] [DATETIME] NOT NULL,
  [LowTemperature] [NUMERIC](6, 2) NULL,
  [HighTemperature] [NUMERIC](6, 2) NULL,
  [Notify] [VARCHAR](18) NULL,
  [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  [user_name] [VARCHAR](128) NOT NULL,
  [entry_date_tm] [DATETIME] NOT NULL,
  [Container] [entityID] NOT NULL,
  [Created]	DATETIME,
  [CreatedBy] USERID,
  [Modified]	DATETIME,
  [ModifiedBy] USERID

  CONSTRAINT [PK_LocationTemperature] PRIMARY KEY CLUSTERED ([Room] ASC,[Date] ASC)
  CONSTRAINT FK_snprc_LocationTemperature_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

  )
  GO


CREATE UNIQUE INDEX idx_snprc_LocationTemperature_objectid ON snprc_ehr.LocationTemperature (ObjectId);
CREATE UNIQUE INDEX idx_snprc_LocationTemperature_Room ON snprc_ehr.LocationTemperature (Room);
GO
