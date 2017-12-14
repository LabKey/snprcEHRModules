CREATE TABLE [snprc_ehr].[ValidChargeBySpecies](
  [Project] INTEGER NOT NULL,
  [Species] NVARCHAR(2) NOT NULL,
  [Purpose] NVARCHAR (2) NOT NULL,
  [ObjectId] nvarchar(128),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [DiCreated] [DATETIME] NULL,
  [DiModified] [DATETIME] NULL,
  [DiCreatedBy] [dbo].[USERID] NULL,
  [DiModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL


    CONSTRAINT PK_snprc_ValidChargeBySpecies PRIMARY KEY ([Project])
    CONSTRAINT FK_snprc_ValidChargeBySpecies_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

go


ALTER TABLE [snprc_ehr].[ValidChargeBySpecies] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO
