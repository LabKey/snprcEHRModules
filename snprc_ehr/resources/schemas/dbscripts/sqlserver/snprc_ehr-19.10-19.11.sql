EXEC core.fn_dropifexists 'LocationTemperature','snprc_ehr', 'TABLE';

GO
/*************************************
ObjectId should be populated before insert.


srr 02.25.2019 ori
srr 02.27.2019 19.11 version
*************************************/

CREATE TABLE [snprc_ehr].[LocationTemperature](
  [Room] [varchar](100) NOT NULL,
  [Date] [DATETIME] NOT NULL,
  [LowTemperature] [NUMERIC](6, 2) NULL,
  [HighTemperature] [NUMERIC](6, 2) NULL,
  [Notify] [VARCHAR](18) NULL,
  [Created] [datetime] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [datetime] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [diCreated] [datetime] NULL,
  [diModified] [datetime] NULL,
  [diCreatedBy] [dbo].[USERID] NULL,
  [diModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL,
  [objectid] [uniqueidentifier] NOT NULL


  CONSTRAINT [PK_LocationTemperature] PRIMARY KEY CLUSTERED ([Room] ASC,[Date] ASC)
  CONSTRAINT FK_snprc_LocationTemperature_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

  )
  GO


CREATE UNIQUE INDEX idx_snprc_LocationTemperature_objectid ON snprc_ehr.LocationTemperature (ObjectId);
CREATE INDEX idx_snprc_LocationTemperature_Date ON snprc_ehr.LocationTemperature (Date, Room);
GO