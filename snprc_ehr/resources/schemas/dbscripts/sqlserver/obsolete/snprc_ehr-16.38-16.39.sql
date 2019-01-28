/*
 * Copyright (c) 2017 LabKey Corporation
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
-- drop existing tables
if exists (select 1
           from  sysobjects
           where  id = object_id('snprc_ehr.lab_tests')
                  and   type = 'U')
  drop table snprc_ehr.lab_tests
GO

if exists (select 1
           from  sysobjects
           where  id = object_id('snprc_ehr.labwork_panels')
                  and   type = 'U')
  drop table snprc_ehr.labwork_panels
GO

if exists (select 1
           from  sysobjects
           where  id = object_id('snprc_ehr.labwork_services')
                  and   type = 'U')
  drop table snprc_ehr.labwork_services
go

if exists (select 1
           from  sysobjects
           where  id = object_id('snprc_ehr.labwork_types')
                  and   type = 'U')
  drop table snprc_ehr.labwork_types
GO

-- labwork_types
CREATE TABLE snprc_ehr.labwork_types (
  RowId [INT] IDENTITY(1,1) NOT NULL,
  ServiceType varchar(100) NOT NULL,
  ObjectId nvarchar(4000),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [DiCreated] [DATETIME] NULL,
  [DiModified] [DATETIME] NULL,
  [DiCreatedBy] [dbo].[USERID] NULL,
  [DiModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_labwork_types PRIMARY KEY (ServiceType),
  CONSTRAINT FK_snprc_labwork_types_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

ALTER TABLE [snprc_ehr].[labwork_types] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO


-- labwork_services

CREATE TABLE snprc_ehr.labwork_services (
  RowId [INT] IDENTITY(1,1) NOT NULL,
  ServiceName varchar(100) NOT NULL,
  ServiceId INT NOT NULL,
  Dataset varchar(100),
  ChargeType varchar(100),
  CollectionMethod varchar(500),
  AlertOnComplete bit,
  Tissue varchar(100),
  OutsideLab bit,
  DateDisabled datetime,
  Method varchar(100),
  Active INT,
  Bench varchar(20),
  ObjectId nvarchar(4000),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [DiCreated] [DATETIME] NULL,
  [DiModified] [DATETIME] NULL,
  [DiCreatedBy] [dbo].[USERID] NULL,
  [DiModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (ServiceId),
  CONSTRAINT FK_snprc_labwork_services_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

ALTER TABLE [snprc_ehr].[labwork_services] ADD  DEFAULT (NEWID()) FOR [ObjectId]
GO

CREATE UNIQUE INDEX idx_labwork_services_serviceId ON [snprc_ehr].[labwork_services](ServiceId);
GO

ALTER TABLE [snprc_ehr].[labwork_services]  WITH CHECK ADD  CONSTRAINT [FK_snprc_labwork_panels_dataset] FOREIGN KEY([Dataset])
REFERENCES [snprc_ehr].[labwork_types] ([ServiceType])
GO

ALTER TABLE [snprc_ehr].[labwork_services] CHECK CONSTRAINT [FK_snprc_labwork_panels_dataset]
GO
-- labwork_panels

CREATE TABLE [snprc_ehr].[labwork_panels](
  RowId [INT] IDENTITY(1,1) NOT NULL,
  [ServiceId] INT NOT NULL,
  [TestId] [VARCHAR](100) NOT NULL,
  [TestName] [VARCHAR](100) NULL,
  [Units] [VARCHAR](100) NULL,
  [SortOrder] INT NULL,
  [Aliases] [VARCHAR](1000) NULL,
  [AlertOnAbnormal] [BIT] NULL,
  [AlertOnAny] [BIT] NULL,
  [IncludeInPanel] [BIT] NULL,
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL,
  [DiCreated] [DATETIME] NULL,
  [DiModified] [DATETIME] NULL,
  [DiCreatedBy] [dbo].[USERID] NULL,
  [DiModifiedBy] [dbo].[USERID] NULL,
  [ObjectId] [UNIQUEIDENTIFIER] NOT NULL,
  CONSTRAINT [PK_snprc_labwork_panels] PRIMARY KEY CLUSTERED
    (
      [RowId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [snprc_ehr].[labwork_panels] ADD  DEFAULT (NEWID()) FOR [objectid]
GO

ALTER TABLE [snprc_ehr].[labwork_panels]  WITH CHECK ADD  CONSTRAINT [FK_snprc_labwork_panels_container] FOREIGN KEY([Container])
REFERENCES [core].[Containers] ([EntityId])
GO

ALTER TABLE [snprc_ehr].[labwork_panels] CHECK CONSTRAINT [FK_snprc_labwork_panels_container]
GO

ALTER TABLE [snprc_ehr].[labwork_panels]  WITH CHECK ADD  CONSTRAINT [FK_snprc_labwork_panels_services] FOREIGN KEY([ServiceId])
REFERENCES [snprc_ehr].[labwork_services] ([ServiceId])
GO

ALTER TABLE [snprc_ehr].[labwork_panels] CHECK CONSTRAINT [FK_snprc_labwork_panels_services]
GO