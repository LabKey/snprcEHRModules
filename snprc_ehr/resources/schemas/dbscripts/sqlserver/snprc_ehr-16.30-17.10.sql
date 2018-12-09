/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
ALTER TABLE snprc_ehr.labwork_services ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.labwork_services ADD diModified DATETIME;
ALTER TABLE snprc_ehr.labwork_services ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.labwork_services ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.lab_tests ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.lab_tests ADD diModified DATETIME;
ALTER TABLE snprc_ehr.lab_tests ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.lab_tests ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package_category ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package_category ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package_category ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package_category ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package_category_junction ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package_category_junction ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package_category_junction ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package_category_junction ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validAccounts ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validAccounts ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validAccounts ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validAccounts ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validInstitutions ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validInstitutions ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validInstitutions ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validInstitutions ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.species ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.species ADD diModified DATETIME;
ALTER TABLE snprc_ehr.species ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.species ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validVets ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validVets ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validVets ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validVets ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.species ADD primate VARCHAR(1);

ALTER TABLE snprc_ehr.validAccounts DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.validAccounts DROP COLUMN userName;

ALTER TABLE snprc_ehr.labwork_services DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.labwork_services DROP COLUMN userName;

ALTER TABLE snprc_ehr.lab_tests DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.lab_tests DROP COLUMN userName;

CREATE TABLE snprc_ehr.animal_group_categories(
  category_code int NOT NULL,
  description varchar(128) NULL,
  comment varchar(128) NULL,
  displayable char(1) NOT NULL,
  species char(2) NULL,
  sex char(1) NULL,
  enforce_exclusivity char(1) NOT NULL,
  allow_future_date char(1) NOT NULL,
  sort_order int NULL,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  diCreated DATETIME,
  diModified DATETIME,
  diCreatedBy USERID,
  diModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_animal_group_categories PRIMARY KEY (category_code),
  CONSTRAINT FK_animal_group_categories FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.animal_groups(
  code INT NOT NULL,
  category_code INT NOT NULL,
  description VARCHAR(128) NOT NULL,
  date DATE NOT NULL,
  enddate DATE NULL,
  comment VARCHAR(MAX) NULL,
  sort_order  INT NULL,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  diCreated DATETIME,
  diModified DATETIME,
  diCreatedBy USERID,
  diModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_animal_groups PRIMARY KEY (code, category_code),
  CONSTRAINT FK_snprc_animal_groups FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

EXEC sp_rename 'snprc_ehr.animal_groups.description', 'name', 'COLUMN';
GO

-- DROP the object id column
-- ADD the objectid back as a uniqueidentifier

ALTER TABLE snprc_ehr.species DROP COLUMN objectid;
ALTER TABLE snprc_ehr.species ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.package_category DROP COLUMN objectid;
ALTER TABLE snprc_ehr.package_category ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.package_category_junction DROP COLUMN objectid;
ALTER TABLE snprc_ehr.package_category_junction ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.animal_groups DROP COLUMN objectid;
ALTER TABLE snprc_ehr.animal_groups ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.validVets DROP COLUMN objectid;
ALTER TABLE snprc_ehr.validVets ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.lab_tests DROP COLUMN objectid;
ALTER TABLE snprc_ehr.lab_tests ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.validAccounts DROP COLUMN objectid;
ALTER TABLE snprc_ehr.validAccounts ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.valid_bd_status DROP COLUMN objectid;
ALTER TABLE snprc_ehr.valid_bd_status ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.valid_birth_code DROP COLUMN objectid;
ALTER TABLE snprc_ehr.valid_birth_code ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.valid_death_code DROP COLUMN objectid;
ALTER TABLE snprc_ehr.valid_death_code ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.animal_group_categories DROP COLUMN objectid;
ALTER TABLE snprc_ehr.animal_group_categories ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.validInstitutions DROP COLUMN objectid;
ALTER TABLE snprc_ehr.validInstitutions ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.package DROP COLUMN objectid;
ALTER TABLE snprc_ehr.package ADD objectid uniqueidentifier not null default newid();

ALTER TABLE snprc_ehr.clinical_observation_datasets ADD objectid uniqueidentifier not null default newid();

-- create a unique index on the objectid
CREATE UNIQUE INDEX idx_species_objectid ON snprc_ehr.species (objectid)
CREATE UNIQUE INDEX idx_package_category_objectid ON snprc_ehr.package_category (objectid)
CREATE UNIQUE INDEX idx_package_category_junction_objectid ON snprc_ehr.package_category_junction (objectid)
CREATE UNIQUE INDEX idx_animal_groups_objectid ON snprc_ehr.animal_groups (objectid)
CREATE UNIQUE INDEX idx_validVets_objectid ON snprc_ehr.validVets (objectid)
CREATE UNIQUE INDEX idx_lab_tests_objectid ON snprc_ehr.lab_tests (objectid)
CREATE UNIQUE INDEX idx_validAccounts_objectid ON snprc_ehr.validAccounts (objectid)
CREATE UNIQUE INDEX idx_valid_bd_status_objectid ON snprc_ehr.valid_bd_status (objectid)
CREATE UNIQUE INDEX idx_valid_birth_code_objectid ON snprc_ehr.valid_birth_code (objectid)
CREATE UNIQUE INDEX idx_valid_death_code_objectid ON snprc_ehr.valid_death_code (objectid)
CREATE UNIQUE INDEX idx_animal_group_categories_objectid ON snprc_ehr.animal_group_categories (objectid)
CREATE UNIQUE INDEX idx_validInstitutions_objectid ON snprc_ehr.validInstitutions (objectid)
CREATE UNIQUE INDEX idx_package_objectid ON snprc_ehr.package (objectid)

-- add unique index on code column in snprc_ehr.animal_groups
CREATE UNIQUE INDEX idx_animal_groups_code ON snprc_ehr.animal_groups (code)

-- Need to change the primary key - recreate labwork_services table - The table will need to be repopulated using the ETL process

IF exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'labwork_services' AND TABLE_SCHEMA = 'snprc_ehr')
  drop table snprc_ehr.labwork_services

CREATE TABLE snprc_ehr.labwork_services (
  rowId int identity,
  serviceName varchar(200) NOT NULL,
  serviceId varchar(200) NOT NULL,
  dataset varchar(200),
  chargeType varchar(200),
  collectionMethod varchar(500),
  alertOnComplete bit,
  tissue varchar(100),
  outsideLab bit,
  dateDisabled datetime,
  method varchar(100),
  objectid UNIQUEIDENTIFIER not null default newid(),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  diCreated DATETIME,
  diModified DATETIME,
  diCreatedBy USERID,
  diModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (rowId),
  CONSTRAINT FK_snprc_labwork_services FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_labwork_services_serviceName ON snprc_ehr.labwork_services (serviceName)
CREATE UNIQUE INDEX idx_labwork_services_serviceId ON snprc_ehr.labwork_services (serviceId)
CREATE UNIQUE INDEX idx_labwork_services_objectid ON snprc_ehr.labwork_services (objectid)

ALTER TABLE snprc_ehr.species ADD Created DATETIME;
ALTER TABLE snprc_ehr.species ADD Modified DATETIME;
ALTER TABLE snprc_ehr.species ADD CreatedBy USERID;
ALTER TABLE snprc_ehr.species ADD ModifiedBy USERID;

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