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
CREATE TABLE [snprc_ehr].[MhcData](
  [Id] [nvarchar](32) NOT NULL,
  [Haplotype] [nvarchar](128) NOT NULL,
  [RowId] [bigint] IDENTITY(1,1) NOT NULL,
  [OcId] [NVARCHAR](128) NULL,
  [MhcValue] [nvarchar](128) NULL,
  [DataFileSource] [nvarchar](4000) NULL,
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


    CONSTRAINT PK_snprc_MhcData PRIMARY KEY ([RowId])
    CONSTRAINT FK_snprc_MhcData_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

go


ALTER TABLE [snprc_ehr].[MhcData] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

ALTER TABLE [snprc_ehr].[MhcData] ADD  CONSTRAINT [AK_ID_Haplotype] UNIQUE NONCLUSTERED
  (
    [Id] ASC,
    [Haplotype] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

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

EXEC core.fn_dropifexists 'FeeSchedule','snprc_ehr', 'TABLE';
GO

CREATE TABLE [snprc_ehr].[FeeSchedule](
  [RowId] [bigint] IDENTITY(1,1) NOT NULL,
  [ActivityId] INTEGER NOT NULL,
  [Species] NVARCHAR(128) NOT NULL,
  [Description] NVARCHAR (256) NOT NULL,
  [BudgetYear] NVARCHAR (256) NOT NULL,
  [Cost] NUMERIC (9,2) NOT NULL,
  [FileName] NVARCHAR (256) NOT NULL,
  [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL


    CONSTRAINT PK_snprc_fee_schedule PRIMARY KEY ([RowId])
    CONSTRAINT FK_snprc_fee_Schedule_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

CREATE UNIQUE INDEX idx_snprc_fee_schedule_objectid ON snprc_ehr.feeSchedule (objectid)
CREATE UNIQUE INDEX idx_snprc_fee_schedule_activityId_budgetYear ON snprc_ehr.FeeSchedule (ActivityId, BudgetYear);