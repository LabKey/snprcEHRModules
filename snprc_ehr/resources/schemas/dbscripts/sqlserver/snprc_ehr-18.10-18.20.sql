/*
 * Copyright (c) 2018 LabKey Corporation
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
EXEC core.fn_dropifexists 'FeeSchedule','snprc_ehr', 'TABLE';
EXEC core.fn_dropifexists 'FeeScheduleSpeciesLookup','snprc_ehr', 'TABLE';
GO

CREATE TABLE [snprc_ehr].[FeeSchedule](
  [RowId] [bigint] IDENTITY(1,1) NOT NULL,
  [StartingYear] INTEGER NOT NULL,
  [VersionLabel] NVARCHAR(128) NOT NULL,
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
CREATE UNIQUE INDEX idx_snprc_fee_schedule_activityId_budgetYear ON snprc_ehr.FeeSchedule (StartingYear, VersionLabel, ActivityId, BudgetYear);
GO

CREATE TABLE [snprc_ehr].[FeeScheduleSpeciesLookup] (
  [FsSpecies] [VARCHAR](128) NOT NULL,
  [SpeciesCode] [VARCHAR](2) NOT NULL,
  [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL

  CONSTRAINT [PK_FeeScheduleSpeciesLookup] PRIMARY KEY CLUSTERED ([FsSpecies], [SpeciesCode])
  CONSTRAINT [FK_FeeScheduleSpeciesLookup_container] FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );
GO

ALTER TABLE snprc_ehr.package ADD pkgType NVARCHAR(1) not null default 'U';