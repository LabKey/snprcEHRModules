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

-- ALTER TABLE snprc_ehr.labwork_services DROP COLUMN objectid;
-- ALTER TABLE snprc_ehr.labwork_services ADD objectid uniqueidentifier not null default newid();

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
--CREATE UNIQUE INDEX idx_labwork_services_objectid ON snprc_ehr.labwork_services (objectid)
CREATE UNIQUE INDEX idx_validAccounts_objectid ON snprc_ehr.validAccounts (objectid)
CREATE UNIQUE INDEX idx_valid_bd_status_objectid ON snprc_ehr.valid_bd_status (objectid)
CREATE UNIQUE INDEX idx_valid_birth_code_objectid ON snprc_ehr.valid_birth_code (objectid)
CREATE UNIQUE INDEX idx_valid_death_code_objectid ON snprc_ehr.valid_death_code (objectid)
CREATE UNIQUE INDEX idx_animal_group_categories_objectid ON snprc_ehr.animal_group_categories (objectid)
CREATE UNIQUE INDEX idx_validInstitutions_objectid ON snprc_ehr.validInstitutions (objectid)
CREATE UNIQUE INDEX idx_package_objectid ON snprc_ehr.package (objectid)

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

CREATE INDEX idx_labwork_services_serviceName ON snprc_ehr.labwork_services (serviceName)
CREATE UNIQUE INDEX idx_labwork_services_objectid ON snprc_ehr.labwork_services (objectid)
