/*
 * Copyright (c) 2018-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

CREATE SCHEMA snprc_r24;
GO

CREATE TABLE [snprc_R24].[Biomarkers](
  [RowId] [bigint] IDENTITY(1,1) NOT NULL,
  [SampleId] [NVARCHAR](32) NOT NULL,
  [Lab] [nvarchar](128) NULL,
  [Analyte] [nvarchar](128) NOT NULL,
  [ObjectId] nvarchar(128),
  [Value] numeric(6,2),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [DiCreated] [DATETIME] NULL,
  [DiModified] [DATETIME] NULL,
  [DiCreatedBy] [dbo].[USERID] NULL,
  [DiModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL


    CONSTRAINT PK_snprc_r24_Biomarkers PRIMARY KEY ([SampleId], [Analyte])
    CONSTRAINT FK_snprc_r24_Biomarkers_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

go

ALTER TABLE [snprc_r24].[Biomarkers] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

/* snprc_r24-17.10-17.20.sql */

CREATE TABLE [snprc_r24].[SampleInventory](
	[RowId] [bigint] IDENTITY(1,1) NOT NULL,
	[AnimalId] [NVARCHAR](32) NOT NULL,
	[Date] [DATETIME] NOT NULL,
	[SampleId] [NVARCHAR](32) NOT NULL,
	[Aim] [NVARCHAR](128) NULL,
	[SampleType] [NVARCHAR](128) NOT NULL,
	[ObjectId] nvarchar(128) NULL,
	[Created] [DATETIME] NULL,
	[CreatedBy] [dbo].[USERID] NULL,
	[Modified] [DATETIME] NULL,
	[ModifiedBy] [dbo].[USERID] NULL,
	[DiCreated] [DATETIME] NULL,
	[DiModified] [DATETIME] NULL,
	[DiCreatedBy] [dbo].[USERID] NULL,
	[DiModifiedBy] [dbo].[USERID] NULL,
	Container	entityId NOT NULL

 CONSTRAINT [pk_snprc_r24_sampleinventory] PRIMARY KEY (	[SampleId] ASC)
 CONSTRAINT [fk_snprc_r24_sampleinventory_container] FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

GO

ALTER TABLE [snprc_r24].[SampleInventory] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

CREATE TABLE [snprc_r24].[lookupSets](
	[RowId] [bigint] IDENTITY(1,1) NOT NULL,
	[SetName] [NVARCHAR](32) NOT NULL,
	[Label] [NVARCHAR](32) NOT NULL,
	[ObjectId] nvarchar(128) NULL,
	[Created] [DATETIME] NULL,
	[CreatedBy] [dbo].[USERID] NULL,
	[Modified] [DATETIME] NULL,
	[ModifiedBy] [dbo].[USERID] NULL,
	[DiCreated] [DATETIME] NULL,
	[DiModified] [DATETIME] NULL,
	[DiCreatedBy] [dbo].[USERID] NULL,
	[DiModifiedBy] [dbo].[USERID] NULL,
	Container	entityId NOT NULL

 CONSTRAINT [pk_snprc_r24_lookupsets] PRIMARY KEY (	[RowId] ASC)
 CONSTRAINT [fk_snprc_r24_lookupsets_container] FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_snprc_r24_lookupSets_setname] ON [snprc_r24].[lookupSets] ( [SetName] ASC )
GO

ALTER TABLE [snprc_r24].[LookupSets] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

CREATE TABLE [snprc_r24].[lookups](
	[RowId] [bigint] IDENTITY(1,1) NOT NULL,
	[SetName] [NVARCHAR](32) NOT NULL,
	[Value] [NVARCHAR](128) NOT NULL,
	[SortOrder] [INTEGER] NULL,
	[DateDisabled] [datetime] NULL,
	[ObjectId] nvarchar(128) NULL,
	[Created] [DATETIME] NULL,
	[CreatedBy] [dbo].[USERID] NULL,
	[Modified] [DATETIME] NULL,
	[ModifiedBy] [dbo].[USERID] NULL,
	[DiCreated] [DATETIME] NULL,
	[DiModified] [DATETIME] NULL,
	[DiCreatedBy] [dbo].[USERID] NULL,
	[DiModifiedBy] [dbo].[USERID] NULL,
	Container	entityId NOT NULL

 CONSTRAINT [pk_snprc_r24_lookups] PRIMARY KEY (	[RowId] ASC),
 CONSTRAINT [fk_snprc_r24_lookups_SetName] FOREIGN KEY (SetName) REFERENCES snprc_r24.LookupSets (SetName),
 CONSTRAINT [fk_snprc_r24_lookups_container] FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_snprc_r24_lookups_setname] ON [snprc_r24].[lookups] ( [SetName] ASC, [VALUE] ASC)
GO

ALTER TABLE [snprc_r24].[Lookups] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

/* snprc_r24-18.10-18.20.sql */

ALTER TABLE snprc_r24.SampleInventory ADD SampleWeight NUMERIC(7,2) NULL;
ALTER TABLE snprc_r24.SampleInventory ADD SampleAmount NUMERIC(7,2) NULL;

CREATE TABLE [snprc_r24].[RowsToDelete](
[ObjectId] [dbo].[EntityId] NOT NULL,
[Modified] [DATETIME] NOT NULL
CONSTRAINT [pk_snprc_r24_RowsToDelete] PRIMARY KEY (	[ObjectId] ASC) );

GO

CREATE TABLE [snprc_r24].[WeightStaging] (
[AnimalId] [NVARCHAR](32) NOT NULL,
[Date] [DATETIME] NOT NULL,
[Weight] [NUMERIC](7,4) NOT NULL,
[ObjectId] [dbo].EntityId NOT NULL,
[Created] [DATETIME] NULL,
[CreatedBy] [dbo].[USERID] NULL,
[Modified] [DATETIME] NULL,
[ModifiedBy] [dbo].[USERID] NULL

CONSTRAINT [pk_snprc_r24_weight_staging] PRIMARY KEY (	[ObjectId] ASC) );

GO