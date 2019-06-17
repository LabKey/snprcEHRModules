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

-- Create schema, tables, indexes, and constraints used for SNPRC_EHR module here
-- All SQL VIEW definitions should be created in snprc_ehr-create.sql and dropped in snprc_ehr-drop.sql
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