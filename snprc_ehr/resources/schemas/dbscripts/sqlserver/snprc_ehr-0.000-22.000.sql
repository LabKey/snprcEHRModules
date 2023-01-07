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

CREATE SCHEMA snprc_ehr;
GO

CREATE TABLE snprc_ehr.package (
    id int not null,
    name NVARCHAR(100),
    description NVARCHAR(MAX),
    Container	entityId NOT NULL,

    CONSTRAINT PK_packages PRIMARY KEY (id),
    CONSTRAINT FK_packages_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_ehr.package_category (
    id int not null,
    name NVARCHAR(100),
    description NVARCHAR(MAX),
    Container	entityId NOT NULL,

    CONSTRAINT PK_package_categories PRIMARY KEY (id),
    CONSTRAINT FK_package_categories_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE TABLE snprc_ehr.package_category_junction (
    rowId int not null,
    packageId int not null,
    categoryId int not null,

    CONSTRAINT PK_package_category_junction PRIMARY KEY (rowId),
    CONSTRAINT FK_package_category_junction_packageId FOREIGN KEY (packageId) REFERENCES snprc_ehr.package(id),
    CONSTRAINT FK_package_category_junction_categoryId FOREIGN KEY (categoryId) REFERENCES snprc_ehr.package_category(id)
);
GO

CREATE UNIQUE INDEX IDX_package_category_junction ON snprc_ehr.package_category_junction(categoryId, packageId);

ALTER TABLE snprc_ehr.package_category DROP COLUMN name;

 ALTER TABLE snprc_ehr.package ADD Created DATETIME;
 ALTER TABLE snprc_ehr.package ADD CreatedBy USERID;
 ALTER TABLE snprc_ehr.package ADD Modified DATETIME;
 ALTER TABLE snprc_ehr.package ADD ModifiedBy USERID;

 ALTER TABLE snprc_ehr.package_category ADD Created DATETIME;
 ALTER TABLE snprc_ehr.package_category ADD CreatedBy USERID;
 ALTER TABLE snprc_ehr.package_category ADD Modified DATETIME;
 ALTER TABLE snprc_ehr.package_category ADD ModifiedBy USERID;

 ALTER TABLE snprc_ehr.package_category_junction ADD Created DATETIME;
 ALTER TABLE snprc_ehr.package_category_junction ADD CreatedBy USERID;
 ALTER TABLE snprc_ehr.package_category_junction ADD Modified DATETIME;
 ALTER TABLE snprc_ehr.package_category_junction ADD ModifiedBy USERID;

ALTER TABLE snprc_ehr.package ADD objectid nvarchar(4000);

 ALTER TABLE snprc_ehr.package_category ADD objectid nvarchar(4000);

 ALTER TABLE snprc_ehr.package_category_junction ADD objectid nvarchar(4000);

GO

CREATE PROCEDURE snprc_ehr.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT column_name
            FROM information_schema.columns
            WHERE table_name='package' and table_schema='snprc_ehr' and column_name='objectid')
        BEGIN
        -- Run variants of scripts from trunk

        ALTER TABLE snprc_ehr.package ADD objectid nvarchar(4000);
        ALTER TABLE snprc_ehr.package_category ADD objectid nvarchar(4000);
        ALTER TABLE snprc_ehr.package_category_junction ADD objectid nvarchar(4000);
        END
    END;

GO

EXEC snprc_ehr.handleUpgrade
GO

DROP PROCEDURE snprc_ehr.handleUpgrade
GO

-- Alters existing ehr_lookups.species table to include additional SNPRC species code columns columns needed
-- for ETLs (objectid)

CREATE PROCEDURE snprc_ehr.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT column_name
            FROM information_schema.columns
            WHERE table_name='species' and table_schema='ehr_lookups' and column_name='objectid')
        BEGIN
        -- Run variants of scripts from trunk

						ALTER TABLE ehr_lookups.species ADD species_code nvarchar(3);
						ALTER TABLE ehr_lookups.species ADD arc_species_code nvarchar(3);
						--ALTER TABLE ehr_lookups.species ADD arc_common_name nvarchar(255);
						--ALTER TABLE ehr_lookups.species ADD arc_scientific_name nvarchar(255);
						ALTER TABLE ehr_lookups.species ADD objectid nvarchar(4000);
						ALTER TABLE ehr_lookups.species ADD tid int;
        END
    END;

GO

EXEC snprc_ehr.handleUpgrade
GO

DROP PROCEDURE snprc_ehr.handleUpgrade
GO

-- Use custom SNPRC species table instead of ehr_lookups.species

ALTER TABLE ehr_lookups.species DROP COLUMN species_code;
ALTER TABLE ehr_lookups.species DROP COLUMN arc_species_code;
ALTER TABLE ehr_lookups.species DROP COLUMN objectid;
ALTER TABLE ehr_lookups.species DROP COLUMN tid;

CREATE TABLE snprc_ehr.species
(
	common NVARCHAR(255) NOT NULL,
	scientific_name NVARCHAR(255),
	id_prefix NVARCHAR(255),
	mhc_prefix NVARCHAR(255),
	blood_per_kg FLOAT,
	max_draw_pct FLOAT,
	blood_draw_interval FLOAT,
	dateDisabled DATETIME NULL,
	cites_code NVARCHAR(200),
	species_code NVARCHAR(3),
	arc_species_code NVARCHAR(3),
	objectid NVARCHAR(4000),
	tid INT,
  CONSTRAINT pk_species PRIMARY KEY (common )
);

-- change primary key to species_code column

TRUNCATE TABLE snprc_ehr.species

ALTER TABLE snprc_ehr.species ALTER COLUMN species_code NVARCHAR(3) NOT NULL
ALTER TABLE snprc_ehr.species ALTER COLUMN arc_species_code NVARCHAR(3)  NOT NULL
ALTER TABLE snprc_ehr.species DROP CONSTRAINT pk_species
ALTER TABLE snprc_ehr.species ADD CONSTRAINT pk_species PRIMARY KEY (species_code)

CREATE TABLE snprc_ehr.clinical_observation_datasets
(
  rowId Int NOT NULL,
	dataset_name NVARCHAR(255) NOT NULL,
	category_name NVARCHAR(255) NOT NULL,
	sort_order Int NULL,
	Container	entityId NOT NULL,

    CONSTRAINT pk_clinical_observation_datasets PRIMARY KEY (rowId),
    CONSTRAINT FK_clinical_observation_datasets_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
    );

GO

CREATE TABLE snprc_ehr.validAccounts(
	account varchar(16) NOT NULL,
	accountStatus varchar(1) NOT NULL,
	date DATETIME NOT NULL,
	endDate DATETIME NULL,
	description VARCHAR(100) NULL,
	accountGroup VARCHAR(20) NOT NULL,
	userName VARCHAR(128) NOT NULL,
	entryDateTm DATETIME NOT NULL,
	Container	entityId NOT NULL,
	Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
	objectid NVARCHAR(4000)

 CONSTRAINT [PK_VALID_ACCOUNTS] PRIMARY KEY CLUSTERED (	account ASC )

);
GO

CREATE TABLE snprc_ehr.lab_tests (
  rowid int identity(1,1),
  type varchar(100),
  testid varchar(100) NOT NULL,
  name varchar(100),
  units varchar(100),
  aliases varchar(1000),
  alertOnAbnormal bit,
  alertOnAny bit,
  includeInPanel bit,
  sort_order int,
  userName VARCHAR(128) NOT NULL,
  entryDateTm DATETIME NOT NULL,
  objectid nvarchar(4000),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

CONSTRAINT PK_snprc_lab_tests PRIMARY KEY (rowid),
CONSTRAINT FK_snprc_lab_tests FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE INDEX IDX_snprc_lab_tests_test_id ON snprc_ehr.lab_tests (testid);

GO


CREATE TABLE snprc_ehr.labwork_services (
  servicename varchar(200) NOT NULL,
  serviceid varchar(200) NOT NULL,
  dataset varchar(200),
  chargetype varchar(200),
  collectionmethod varchar(500),
  alertOnComplete bit,
  tissue varchar(100),
  outsidelab bit,
  datedisabled datetime,
  method varchar(100),
  userName VARCHAR(128) NOT NULL,
  entryDateTm DATETIME NOT NULL,
  objectid nvarchar(4000),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (servicename),
  CONSTRAINT FK_snprc_labwork_services FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.validInstitutions (
  institution_id integer NOT NULL ,
  institution_name varchar(200) NOT NULL,
  short_name varchar(20) NOT NULL,
  city varchar(50) NOT NULL,
  state varchar(20) NOT NULL,
  affiliate varchar(50) NULL,
  web_site varchar(200) NULL,
  objectid nvarchar(4000) NOT NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

CONSTRAINT PK_snprc_valid_institutions PRIMARY KEY (institution_id),
CONSTRAINT FK_snprc_valid_institutions FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.validVets (
  vetId  integer NOT NULL,
  displayName varchar(128) NOT NULL ,
  emailAddress varchar(128) NULL,
  status varchar(10) NOT NULL,
  objectid nvarchar(4000) NOT NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_validVets PRIMARY KEY (vetId),
  CONSTRAINT FK_snprc_validVets FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.valid_bd_status (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_bd_status PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_bd_status FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO
CREATE TABLE snprc_ehr.valid_birth_code (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_birth_code PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_birth_code FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.valid_death_code (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_death_code PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_death_code FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

/* snprc_ehr-16.30-17.10.sql */

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

/* snprc_ehr-17.20-17.30.sql */

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

/* snprc_ehr-18.10-18.20.sql */

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

EXEC core.fn_dropifexists 'valid_birth_code','snprc_ehr', 'TABLE';
EXEC core.fn_dropifexists 'valid_death_code','snprc_ehr', 'TABLE';

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

-- Version 12 is replaced by version 13 srr

EXEC core.fn_dropifexists 'ValidDiet','snprc_ehr', 'TABLE';

--GO;
/***************************************************
Note:  ArcSpeciesCode is null for most rows
      therefore not included in PK
 PK is composite of Diet and StartDate

 Currently: In legacy table, SnomedCode is
            generated using a identity (tid).

            This was refactored to an integer
            DietId.
            May refactor out or to a counter
             value at a later date.

srr 03.11.2019 ori
***************************************************/

CREATE TABLE snprc_ehr.ValidDiet(
  [Diet] [nvarchar](20) NOT NULL,
  [ArcSpeciesCode] [nvarchar](2) NULL,
  [StartDate] [datetime] NOT NULL,
  [StopDate] [datetime] NULL,
  [SnomedCode] [nvarchar](7) NULL,
  [DietId]	[INTEGER] NOT NULL,
  --ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  --[Container] [entityID] NOT NULL,
  [Created]	DATETIME,
  [CreatedBy] USERID,
  [Modified]	DATETIME,
  [ModifiedBy] USERID,
  [diCreated] [datetime] NULL,
  [diModified] [datetime] NULL,
  [diCreatedBy] [dbo].[USERID] NULL,
  [diModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL,
  [objectid] [uniqueidentifier] NOT NULL
  CONSTRAINT [PK_ValidDiet] PRIMARY KEY CLUSTERED ([Diet] ASC,[StartDate] ASC)
  )

  go

EXEC core.fn_dropifexists 'ValidDiet','snprc_ehr', 'TABLE';

/*****************************************************************
Note:  ArcSpeciesCode is null for most rows
therefore not included in PK
PK is composite of Diet and StartDate

Currently: In legacy table, SnomedCode is
generated using a identity (tid).
As of 03.18.2019 column is now DietCode.

This was refactored to an integer
DietId.
May refactor out or to a counter
value at a later date.

srr 03.11.2019 ori
srr 03.18.2019 To agree w/ naming conventions elsewhere
refactored DietId to DietCode


******************************************************************/

CREATE TABLE snprc_ehr.ValidDiet(
  [Diet] [nvarchar](20) NOT NULL,
  [ArcSpeciesCode] [nvarchar](2) NULL,
  [StartDate] [datetime] NOT NULL,
  [StopDate] [datetime] NULL,
  [SnomedCode] [nvarchar](7) NULL,
  [DietCode]	[INTEGER] NOT NULL,
  --ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  --[Container] [entityID] NOT NULL,
  [Created]	DATETIME,
  [CreatedBy] USERID,
  [Modified]	DATETIME,
  [ModifiedBy] USERID,
  [diCreated] [datetime] NULL,
  [diModified] [datetime] NULL,
  [diCreatedBy] [dbo].[USERID] NULL,
  [diModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL,
  [objectid] [uniqueidentifier] NOT NULL
  CONSTRAINT [PK_ValidDiet] PRIMARY KEY CLUSTERED ([Diet] ASC,[StartDate] ASC)
  )

-- will need to be changed if we begin to use Diet instead of SnomedCode srr
CREATE UNIQUE INDEX idx_ValidDiet_SnomedCode_StartStopDate ON snprc_ehr.ValidDiet(SnomedCode, StartDate, StopDate);
  go

/*********************************************************
Valids for diagnosis (DX) taken from legacy DB.
  Likely needs refactoring.
  Will no do now.
  srr

*********************************************************/



EXEC core.fn_dropifexists 'ValidDXGroup','snprc_ehr', 'TABLE';

--srr 07.17.19

CREATE TABLE snprc_ehr.ValidDXGroup
(
    DXGroup      VARCHAR(30)      NOT NULL,
    Created      DATETIME,
    CreatedBy    USERID,
    Modified     DATETIME,
    ModifiedBy   USERID,
    diCreated    datetime         NULL,
    diModified   datetime         NULL,
    diCreatedBy  dbo.USERID       NULL,
    diModifiedBy dbo.USERID       NULL,
    Container    dbo.ENTITYID     NOT NULL,
    objectid     uniqueidentifier NOT NULL
        CONSTRAINT PK_ValidDXGroup PRIMARY KEY CLUSTERED (DXGroup ASC)
)


EXEC core.fn_dropifexists 'ValidDXList','snprc_ehr', 'TABLE';


--srr 07.17.19

CREATE TABLE snprc_ehr.ValidDXList
(
    DXGroup      VARCHAR(30)      NOT NULL,
    DX VARCHAR(30) NOT NULL,
    Created      DATETIME,
    CreatedBy    USERID,
    Modified     DATETIME,
    ModifiedBy   USERID,
    diCreated    datetime         NULL,
    diModified   datetime         NULL,
    diCreatedBy  dbo.USERID       NULL,
    diModifiedBy dbo.USERID       NULL,
    Container    dbo.ENTITYID     NOT NULL,
    objectid     uniqueidentifier NOT NULL
        CONSTRAINT PK_ValidDXList PRIMARY KEY CLUSTERED (DXGroup ASC, DX ASC)
)

EXEC core.fn_dropifexists 'ValidVaccines','snprc_ehr', 'TABLE';

--srr 07.17.19

CREATE TABLE snprc_ehr.ValidVaccines
(
    Vaccine      VARCHAR(128)      NOT NULL,
    Created      DATETIME,
    CreatedBy    USERID,
    Modified     DATETIME,
    ModifiedBy   USERID,
    diCreated    datetime         NULL,
    diModified   datetime         NULL,
    diCreatedBy  dbo.USERID       NULL,
    diModifiedBy dbo.USERID       NULL,
    Container    dbo.ENTITYID     NOT NULL,
    objectid     uniqueidentifier NOT NULL
        CONSTRAINT PK_ValidVaccine PRIMARY KEY CLUSTERED (Vaccine ASC)
)

-- adding species to the PK
ALTER TABLE snprc_ehr.ValidChargeBySpecies
    DROP CONSTRAINT PK_snprc_ValidChargeBySpecies
GO

ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD CONSTRAINT
    PK_snprc_ValidChargeBySpecies PRIMARY KEY CLUSTERED
(
    Project,
    Species
)

GO

/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change databypes to match those in lookup tables.

*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.NewAnimalData
(
    Id NVARCHAR(32) NOT NULL,
    BirthDate DATETIME NULL,
    AcquisitionType INT NULL,
    AcqDate DATETIME NULL,  -- Will use for all start dates in this dataset
    Gender NVARCHAR(10) NULL,         --gender nvarchar(4000)
    Sire NVARCHAR(32) NULL,
    Dam NVARCHAR(32) NULL,
    Species NVARCHAR(3) NULL, -- species, nvarchar(4000)
    Colony NVARCHAR(400) NULL,
    AnimalAccount NVARCHAR(400) NULL,
    OwnerInstitution INT NULL,       -- lookup snprc_ehr.validInstitutions
    ResponsibleInstitution INT NULL,       -- likely same as owner
    Location NVARCHAR(400) NULL,
    Diet NVARCHAR(400) NULL,
    Pedigree NVARCHAR(400) NULL,
    IACUC NVARCHAR(400) NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    DiCreated DATETIME NULL,
    DiModified DATETIME NULL,
    DiCreatedBy dbo.USERID NULL,
    DiModifiedBy dbo.USERID NULL,
    Container ENTITYID NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_snprc_NEWANIMALDATA   PRIMARY KEY (Id)
);
--[DeliveryType]  [nvarchar](400) NULL,
--[BirthNature]   [nvarchar](400) NULL,
--[AcquireType]   [nvarchar](400) NULL,


/*
Species,
Acq_code,
id_type,
institution_id,
colony,
delivery_type,
birth_nature,
acquire_type,
animalAccounts,
location,
IACUC fields,
pedigree,
diet
 */



go

ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD startDate DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD stopDate DATETIME;

/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change databypes to match those in lookup tables.

srr 03.09.2020 version 20.003
Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';



CREATE TABLE [snprc_ehr].[NewAnimalData](
    [Id] [nvarchar](32) NOT NULL,
    [BirthDate] [datetime] NULL,
    [AcquisitionType] [int] NULL,
    [AcqDate] [datetime] NULL,
    [Gender] [nvarchar](10) NULL,
    [Sire] [nvarchar](32) NULL,
    [Dam] [nvarchar](32) NULL,
    [Species] [nvarchar](3) NULL,
    [Colony] [int] NULL,
    [AnimalAccount] [int] NULL,
    [OwnerInstitution] [int] NULL,
    [ResponsibleInstitution] [int] NULL,
    [Room] [int] NULL,
    [Cage] [int] NULL,
    [Diet] [int] NULL,
    [Pedigree] [int] NULL,
    [IACUC] [int] NULL,
    [Created] [datetime] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [datetime] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [objectid] [uniqueidentifier] NOT NULL,
        CONSTRAINT PK_snprc_NEWANIMALDATA   PRIMARY KEY (Id)
);

-- generated w/o issue from SSMS srr 04.10.20
-- schemas/dbscripts/sqlserver/snprc_ehr-20.003-20.004.sql
EXEC core.fn_dropifexists 'BehaviorNotificationComment','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.BehaviorNotificationComment
(
    NotificationNumber   INT              NOT NULL,
    NotificationDateTm   DATETIME         NOT NULL,
    BehaviorId           INT              NOT NULL,
    NotificationStatus   INT              NOT NULL,
    CaseNumber           INT              NULL,
    NotificationComments VARCHAR(255)     NULL,
    SuspiciousBehavior   CHAR(1)          NOT NULL,
    Sib                  CHAR(1)          NOT NULL,
    HousingType          INT              NULL,
    Behavior             VARCHAR(30)      NOT NULL,
    AbnormalFlag         CHAR(1)          NOT NULL,
    BehaviorDescription  VARCHAR(200)     NOT NULL,
    BehaviorCategory     VARCHAR(40)      NULL,
    BehaviorComments     VARCHAR(200)     NULL,
    Container            ENTITYID         NOT NULL,
    Created              DATETIME         NULL,
    CreatedBy            USERID           NULL,
    ModifiedBy           USERID           NULL,
    Modified             DATETIME         NULL,
    DiCreatedBy          USERID           NULL,
    DiCreated            DATETIME         NULL,
    DiModifiedBy         USERID           NULL,
    DiModified           DATETIME         NULL,
    ObjectId             UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_BehaviorNotiComment PRIMARY KEY (NotificationNumber)
);

-- generated w/o issue from SSMS srr 04.10.20
-- schemas/dbscripts/sqlserver/snprc_ehr-20.003-20.004.sql
-- changed pk to tid idenity
EXEC core.fn_dropifexists 'BehaviorNotificationComment','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.BehaviorNotificationComment
(
    NotificationNumber   INT              NOT NULL,
    NotificationDateTm   DATETIME         NOT NULL,
    BehaviorId           INT              NOT NULL,
    NotificationStatus   INT              NOT NULL,
    CaseNumber           INT              NULL,
    NotificationComments VARCHAR(255)     NULL,
    SuspiciousBehavior   CHAR(1)          NOT NULL,
    Sib                  CHAR(1)          NOT NULL,
    HousingType          INT              NULL,
    Behavior             VARCHAR(30)      NOT NULL,
    AbnormalFlag         CHAR(1)          NOT NULL,
    BehaviorDescription  VARCHAR(200)     NOT NULL,
    BehaviorCategory     VARCHAR(40)      NULL,
    BehaviorComments     VARCHAR(200)     NULL,
    Container            ENTITYID         NOT NULL,
    Created              DATETIME         NULL,
    CreatedBy            USERID           NULL,
    ModifiedBy           USERID           NULL,
    Modified             DATETIME         NULL,
    DiCreatedBy          USERID           NULL,
    DiCreated            DATETIME         NULL,
    DiModifiedBy         USERID           NULL,
    DiModified           DATETIME         NULL,
    tid                  INT              IDENTITY,
    objectid             UNIQUEIDENTIFIER NULL
        CONSTRAINT PK_BehaviorNotiComment_oid PRIMARY KEY (tid)
);

EXEC core.fn_dropifexists 'ValidDefaultIACUC','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.validDefaultIACUC
(
    WorkingIacuc varchar(7)       NOT NULL,
    ArcNumSeq    int              NOT NULL,
    ArcNumGenus varchar(2)       NOT NULL,
    Mandatory    varchar(1)       NULL,
    DefaultIacuc varchar(1)       NULL,
    Container    ENTITYID         NOT NULL,
    Created      DATETIME         NULL,
    CreatedBy    USERID           NULL,
    ModifiedBy   USERID           NULL,
    Modified     DATETIME         NULL,
    DiCreatedBy  USERID           NULL,
    DiCreated    DATETIME         NULL,
    DiModifiedBy USERID           NULL,
    DiModified   DATETIME         NULL,
    ObjectId     UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ValidDefaultIACUC PRIMARY KEY (WorkingIacuc)
);

/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change datatypes to match those in lookup tables.

srr 03.09.2020 version 20.003
  Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
srr 06.08.2020 version 20.007
  Added column for BirthCode.
    1   DOB accurate
    2   Month-Year accurate
    3   Year accurate
  No Real data, therefore dropping table and re-recreating.
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.NewAnimalData
(
    Id                     nvarchar(32)     NOT NULL,
    BirthDate              datetime         NULL,
    BirthCode              int              NULL,
    AcquisitionType        int              NULL,
    AcqDate                datetime         NULL,
    Gender                 nvarchar(10)     NULL,
    Sire                   nvarchar(32)     NULL,
    Dam                    nvarchar(32)     NULL,
    Species                nvarchar(3)      NULL,
    Colony                 int              NULL,
    AnimalAccount          int              NULL,
    OwnerInstitution       int              NULL,
    ResponsibleInstitution int              NULL,
    Room                   int              NULL,
    Cage                   int              NULL,
    Diet                   int              NULL,
    Pedigree               int              NULL,
    IACUC                  int              NULL,
    Created                datetime         NULL,
    CreatedBy              dbo.USERID       NULL,
    Modified               datetime         NULL,
    ModifiedBy             dbo.USERID       NULL,
    Container              dbo.ENTITYID     NOT NULL,
    objectid               uniqueidentifier NOT NULL,
    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);

/******************************************************
Change ValidDiet PK
Script generated by SSMS
srr 06.16.2020
******************************************************/
ALTER TABLE snprc_ehr.ValidDiet
    DROP CONSTRAINT PK_ValidDiet
    GO
ALTER TABLE snprc_ehr.ValidDiet ADD CONSTRAINT
    PK_ValidDiet PRIMARY KEY CLUSTERED
(
    Diet
)

GO
ALTER TABLE snprc_ehr.ValidDiet SET (LOCK_ESCALATION = TABLE)
GO

/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change datatypes to match those in lookup tables.

srr 03.09.2020 version 20.003
  Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
srr 06.08.2020 version 20.007
  Added column for BirthCode.
    1   DOB accurate
    2   Month-Year accurate
    3   Year accurate
  No Real data, therefore dropping table and re-recreating.

 srr 06.24.2020
  Changed Diet, AnimalAccount and IACUC to strings
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.NewAnimalData
(
    Id                     nvarchar(32)     NOT NULL,
    BirthDate              datetime         NULL,
    BirthCode              int              NULL,
    AcquisitionType        int              NULL,
    AcqDate                datetime         NULL,
    Gender                 nvarchar(10)     NULL,
    Sire                   nvarchar(32)     NULL,
    Dam                    nvarchar(32)     NULL,
    Species                nvarchar(3)      NULL,
    Colony                 int              NULL,
    AnimalAccount          nvarchar(16)     NULL,
    OwnerInstitution       int              NULL,
    ResponsibleInstitution int              NULL,
    Room                   int              NULL,
    Cage                   int              NULL,
    Diet                   nvarchar(20)     NULL,
    Pedigree               int              NULL,
    IACUC                  nvarchar(200)    NULL,
    Created                datetime         NULL,
    CreatedBy              dbo.USERID       NULL,
    Modified               datetime         NULL,
    ModifiedBy             dbo.USERID       NULL,
    Container              dbo.ENTITYID     NOT NULL,
    objectid               uniqueidentifier NOT NULL,
    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);

/*******************************************************
Counters table for SNPRC_EHRSequencer
  Creator: thawkins
  Date: 08/21/2020
*******************************************************/

CREATE TABLE snprc_ehr.Counters
(
    RowId                  INT IDENTITY(1,1) NOT NULL,
    Name                   NVARCHAR(255)    NOT NULL,
    Value                  INT              NOT NULL,
    Container              dbo.ENTITYID     NOT NULL,
    ObjectId               UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_snprc_Counters PRIMARY KEY (RowId),
    CONSTRAINT FK_Counters_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_snprc_container_NameValue ON snprc_ehr.Counters (Container, Name, Value);
GO

/*
 * New table to track number of animals allowed and assigned to IACUC protocols
 * 9/25/2020 tjh
 */
EXEC core.fn_dropifexists 'IacucAssignmentStats','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.IacucAssignmentStats
(
    ThreeYearPeriod    INT              NOT NULL,
    WorkingIacuc       NVARCHAR(50)     NOT NULL,
    ArcNumSeq          INT              NOT NULL,
    arcNumGenus        VARCHAR(50)      NOT NULL,
    FirstAmendment     INT              NOT NULL,
    LastAmendment      INT              NOT NULL,
    StartDate          DATETIME         NOT NULL,
    EndDate            DATETIME         NULL,
    NumAnimalsAllowed  INT              NOT NULL,
    NumAnimalsAssigned INT              NOT NULL,
    diCreated          DATETIME,
    diModified         DATETIME,
    diCreatedBy        USERID,
    diModifiedBy       USERID,
    Container          entityId         NOT NULL
    CONSTRAINT PK_IacucAssignmentStats PRIMARY KEY CLUSTERED ( WorkingIacuc ASC, ThreeYearPeriod ASC ),
    CONSTRAINT FK_IacucAssignmentsStats_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
)

/*
 * New table to configure external reports
 *
 */
EXEC core.fn_dropifexists 'ExternalReports','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.ExternalReports
(
    Id                 INT              IDENTITY(1,1),
    SortOrder          INT              NULL,
    Label              NVARCHAR(64)     NOT NULL,
    Report             NVARCHAR(400)    NOT NULL,
    Description        NVARCHAR(4000)   NOT NULL,
    Parameters         NVARCHAR(4000)   NULL,
    rsParameters       NVARCHAR(4000)   NULL,
    Created            DATETIME         DEFAULT GETDATE(),
    Modified           DATETIME         DEFAULT GETDATE(),
    CreatedBy          USERID,
    ModifiedBy         USERID
        CONSTRAINT PK_ExternalReports PRIMARY KEY CLUSTERED ( Id ASC)
)

/* 21.xxx SQL scripts */

/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change datatypes to match those in lookup tables.

srr 03.09.2020 version 20.003
  Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
srr 06.08.2020 version 20.007
  Added column for BirthCode.
    1   DOB accurate
    2   Month-Year accurate
    3   Year accurate
  No Real data, therefore dropping table and re-recreating.

 srr 06.24.2020
  Changed Diet, AnimalAccount and IACUC to strings
 srr 04012021 version 21.000
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.NewAnimalData
(
    Id                     nvarchar(32)     NOT NULL,
    BirthDate              datetime         NULL,
    BirthCode              int              NULL,
    AcquisitionType        int              NULL,
    AcqDate                datetime         NULL,
    SourceInstitutionLocation   nvarchar(10) NULL,
    Gender                 nvarchar(10)     NULL,
    Sire                   nvarchar(32)     NULL,
    Dam                    nvarchar(32)     NULL,
    Species                nvarchar(3)      NULL,
    Colony                 int              NULL,
    AnimalAccount          nvarchar(16)     NULL,
    OwnerInstitution       int              NULL,
    ResponsibleInstitution int              NULL,
    Room                   int              NULL,
    Cage                   int              NULL,
    Diet                   nvarchar(20)     NULL,
    Pedigree               int              NULL,
    IACUC                  nvarchar(200)    NULL,
    Created                datetime         NULL,
    CreatedBy              dbo.USERID       NULL,
    Modified               datetime         NULL,
    ModifiedBy             dbo.USERID       NULL,
    Container              dbo.ENTITYID     NOT NULL,
    objectid               uniqueidentifier NOT NULL,
    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);