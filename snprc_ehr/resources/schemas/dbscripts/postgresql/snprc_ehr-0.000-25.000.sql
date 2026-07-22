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

/*
 * NOTE: Need to:
 * - Fix snprc_ehr.HL7_IMPORT_LOG.TID - IDENTITY columns in PostgreSQL must be int, bigint, smallint, etc. NOT NUMERIC
 * - get_random_uuid
 * - ROWVERSION replaced with BYTEA
 */

CREATE SCHEMA snprc_ehr;

CREATE TABLE snprc_ehr.package (
    id INT NOT NULL,
    name VARCHAR(100),
    description TEXT,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    pkgType VARCHAR(1) NOT NULL DEFAULT 'U',

    CONSTRAINT PK_packages PRIMARY KEY (id),
    CONSTRAINT FK_packages_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_package_objectid ON snprc_ehr.package (objectid);

CREATE TABLE snprc_ehr.package_category (
    id INT NOT NULL,
    description TEXT,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_package_categories PRIMARY KEY (id),
    CONSTRAINT FK_package_categories_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_package_category_objectid ON snprc_ehr.package_category (objectid);

CREATE TABLE snprc_ehr.package_category_junction (
    rowId INT NOT NULL,
    packageId INT NOT NULL,
    categoryId INT NOT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_package_category_junction PRIMARY KEY (rowId),
    CONSTRAINT FK_package_category_junction_packageId FOREIGN KEY (packageId) REFERENCES snprc_ehr.package(id),
    CONSTRAINT FK_package_category_junction_categoryId FOREIGN KEY (categoryId) REFERENCES snprc_ehr.package_category(id)
);

CREATE UNIQUE INDEX IDX_package_category_junction ON snprc_ehr.package_category_junction(categoryId, packageId);
CREATE UNIQUE INDEX idx_package_category_junction_objectid ON snprc_ehr.package_category_junction (objectid);

CREATE TABLE snprc_ehr.species
(
    common VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255),
    id_prefix VARCHAR(255),
    mhc_prefix VARCHAR(255),
    blood_per_kg DOUBLE PRECISION,
    max_draw_pct DOUBLE PRECISION,
    blood_draw_interval DOUBLE PRECISION,
    dateDisabled TIMESTAMP NULL,
    cites_code VARCHAR(200),
    species_code VARCHAR(3) NOT NULL,
    arc_species_code VARCHAR(3) NOT NULL,
    tid INT,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    primate VARCHAR(1),
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP,
    Modified TIMESTAMP,
    CreatedBy USERID,
    ModifiedBy USERID,

    CONSTRAINT pk_species PRIMARY KEY (species_code)
);

CREATE UNIQUE INDEX idx_species_objectid ON snprc_ehr.species (objectid);

CREATE TABLE snprc_ehr.clinical_observation_datasets
(
    rowId INT NOT NULL,
    dataset_name VARCHAR(255) NOT NULL,
    category_name VARCHAR(255) NOT NULL,
    sort_order INT NULL,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT pk_clinical_observation_datasets PRIMARY KEY (rowId),
    CONSTRAINT FK_clinical_observation_datasets_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_ehr.validAccounts(
    account VARCHAR(16) NOT NULL,
    accountStatus VARCHAR(1) NOT NULL,
    date TIMESTAMP NOT NULL,
    endDate TIMESTAMP NULL,
    description VARCHAR(100) NULL,
    accountGroup VARCHAR(20) NOT NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_VALID_ACCOUNTS PRIMARY KEY (account)
);

CREATE UNIQUE INDEX idx_validAccounts_objectid ON snprc_ehr.validAccounts (objectid);

CREATE TABLE snprc_ehr.labwork_services (
    RowId SERIAL NOT NULL,
    ServiceName VARCHAR(100) NOT NULL,
    ServiceId INT NOT NULL,
    Dataset VARCHAR(100),
    ChargeType VARCHAR(100),
    CollectionMethod VARCHAR(500),
    AlertOnComplete BOOLEAN,
    Tissue VARCHAR(100),
    OutsideLab BOOLEAN,
    DateDisabled TIMESTAMP,
    Method VARCHAR(100),
    Active INT,
    Bench VARCHAR(20),
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (ServiceId),
    CONSTRAINT FK_snprc_labwork_services_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_labwork_services_serviceId ON snprc_ehr.labwork_services(ServiceId);

CREATE TABLE snprc_ehr.validInstitutions (
    institution_id INTEGER NOT NULL ,
    institution_name VARCHAR(200) NOT NULL,
    short_name VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(20) NOT NULL,
    affiliate VARCHAR(50) NULL,
    web_site VARCHAR(200) NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    Container ENTITYID NOT NULL,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_snprc_valid_institutions PRIMARY KEY (institution_id),
    CONSTRAINT FK_snprc_valid_institutions FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_validInstitutions_objectid ON snprc_ehr.validInstitutions (objectid);

CREATE TABLE snprc_ehr.validVets (
    vetId INTEGER NOT NULL,
    displayName VARCHAR(128) NOT NULL ,
    emailAddress VARCHAR(128) NULL,
    status VARCHAR(10) NOT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    Container ENTITYID NOT NULL,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_snprc_validVets PRIMARY KEY (vetId),
    CONSTRAINT FK_snprc_validVets FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_validVets_objectid ON snprc_ehr.validVets (objectid);

CREATE TABLE snprc_ehr.valid_bd_status (
    value INTEGER NOT NULL,
    description VARCHAR(128) NOT NULL ,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_snprc_valid_bd_status PRIMARY KEY (value),
    CONSTRAINT FK_snprc_valid_bd_status FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_valid_bd_status_objectid ON snprc_ehr.valid_bd_status (objectid);

CREATE TABLE snprc_ehr.animal_group_categories(
    category_code INT NOT NULL,
    description VARCHAR(128) NULL,
    comment VARCHAR(128) NULL,
    displayable CHAR(1) NOT NULL,
    species CHAR(2) NULL,
    sex CHAR(1) NULL,
    enforce_exclusivity CHAR(1) NOT NULL,
    allow_future_date CHAR(1) NOT NULL,
    sort_order INT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_animal_group_categories PRIMARY KEY (category_code),
    CONSTRAINT FK_animal_group_categories FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_animal_group_categories_objectid ON snprc_ehr.animal_group_categories (objectid);

CREATE TABLE snprc_ehr.animal_groups(
    code INT NOT NULL,
    category_code INT NOT NULL,
    name VARCHAR(128) NOT NULL, -- Renamed from description
    date DATE NOT NULL,
    enddate DATE NULL,
    comment TEXT NULL,
    sort_order INT NULL,
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP,
    diModified TIMESTAMP,
    diCreatedBy USERID,
    diModifiedBy USERID,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_snprc_animal_groups PRIMARY KEY (code, category_code),
    CONSTRAINT FK_snprc_animal_groups FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_animal_groups_objectid ON snprc_ehr.animal_groups (objectid);
CREATE UNIQUE INDEX idx_animal_groups_code ON snprc_ehr.animal_groups (code);

CREATE TABLE snprc_ehr.labwork_types (
    RowId SERIAL NOT NULL,
    ServiceType VARCHAR(100) NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_snprc_labwork_types PRIMARY KEY (ServiceType),
    CONSTRAINT FK_snprc_labwork_types_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

ALTER TABLE snprc_ehr.labwork_services ADD CONSTRAINT FK_snprc_labwork_panels_dataset FOREIGN KEY(Dataset) REFERENCES snprc_ehr.labwork_types (ServiceType);

CREATE TABLE snprc_ehr.labwork_panels(
    RowId SERIAL NOT NULL,
    ServiceId INT NOT NULL,
    TestId VARCHAR(100) NOT NULL,
    TestName VARCHAR(100) NULL,
    Units VARCHAR(100) NULL,
    SortOrder INT NULL,
    Aliases VARCHAR(1000) NULL,
    AlertOnAbnormal BOOLEAN NULL,
    AlertOnAny BOOLEAN NULL,
    IncludeInPanel BOOLEAN NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    CONSTRAINT PK_snprc_labwork_panels PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.labwork_panels ADD CONSTRAINT FK_snprc_labwork_panels_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
ALTER TABLE snprc_ehr.labwork_panels ADD CONSTRAINT FK_snprc_labwork_panels_services FOREIGN KEY(ServiceId) REFERENCES snprc_ehr.labwork_services (ServiceId);

CREATE TABLE snprc_ehr.MhcData(
    Id VARCHAR(32) NOT NULL,
    Haplotype VARCHAR(128) NOT NULL,
    RowId BIGSERIAL NOT NULL,
    OcId VARCHAR(128) NULL,
    MhcValue VARCHAR(128) NULL,
    DataFileSource VARCHAR(4000) NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_snprc_MhcData PRIMARY KEY (RowId),
    CONSTRAINT FK_snprc_MhcData_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

ALTER TABLE snprc_ehr.MhcData ADD CONSTRAINT AK_ID_Haplotype UNIQUE (Id, Haplotype);

CREATE TABLE snprc_ehr.ValidChargeBySpecies(
    Project INTEGER NOT NULL,
    Species VARCHAR(2) NOT NULL,
    Purpose VARCHAR(2) NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    startDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    stopDate TIMESTAMP,

    CONSTRAINT PK_snprc_ValidChargeBySpecies PRIMARY KEY (Project, Species),
    CONSTRAINT FK_snprc_ValidChargeBySpecies_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_ehr.FeeSchedule(
    RowId BIGSERIAL NOT NULL,
    StartingYear INTEGER NOT NULL,
    VersionLabel VARCHAR(128) NOT NULL,
    ActivityId INTEGER NOT NULL,
    Species VARCHAR(128) NOT NULL,
    Description VARCHAR(256) NOT NULL,
    BudgetYear VARCHAR(256) NOT NULL,
    Cost NUMERIC (9,2) NOT NULL,
    FileName VARCHAR(256) NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_snprc_fee_schedule PRIMARY KEY (RowId),
    CONSTRAINT FK_snprc_fee_Schedule_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_fee_schedule_objectid ON snprc_ehr.feeSchedule (objectid);
CREATE UNIQUE INDEX idx_snprc_fee_schedule_activityId_budgetYear ON snprc_ehr.FeeSchedule (StartingYear, VersionLabel, ActivityId, BudgetYear);

CREATE TABLE snprc_ehr.FeeScheduleSpeciesLookup (
    FsSpecies VARCHAR(128) NOT NULL,
    SpeciesCode VARCHAR(2) NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_FeeScheduleSpeciesLookup PRIMARY KEY (FsSpecies, SpeciesCode),
    CONSTRAINT FK_FeeScheduleSpeciesLookup_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_ehr.LocationTemperature(
    Room VARCHAR(100) NOT NULL,
    Date TIMESTAMP NOT NULL,
    LowTemperature NUMERIC(6, 2) NULL,
    HighTemperature NUMERIC(6, 2) NULL,
    Notify VARCHAR(18) NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    diCreated TIMESTAMP NULL,
    diModified TIMESTAMP NULL,
    diCreatedBy USERID NULL,
    diModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_LocationTemperature PRIMARY KEY (Room, Date),
    CONSTRAINT FK_snprc_LocationTemperature_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_LocationTemperature_objectid ON snprc_ehr.LocationTemperature (ObjectId);
CREATE INDEX idx_snprc_LocationTemperature_Date ON snprc_ehr.LocationTemperature (Date, Room);

CREATE TABLE snprc_ehr.ValidDiet(
    Diet VARCHAR(20) NOT NULL,
    ArcSpeciesCode VARCHAR(2) NULL,
    StartDate TIMESTAMP NOT NULL,
    StopDate TIMESTAMP NULL,
    SnomedCode VARCHAR(7) NULL,
    DietCode INTEGER NOT NULL, -- Renamed from DietId
    Created TIMESTAMP,
    CreatedBy USERID,
    Modified TIMESTAMP,
    ModifiedBy USERID,
    diCreated TIMESTAMP NULL,
    diModified TIMESTAMP NULL,
    diCreatedBy USERID NULL,
    diModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    objectid ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_ValidDiet PRIMARY KEY (Diet) -- Changed primary key
);

CREATE UNIQUE INDEX idx_ValidDiet_SnomedCode_StartStopDate ON snprc_ehr.ValidDiet(SnomedCode, StartDate, StopDate);

CREATE TABLE snprc_ehr.ValidDXGroup
(
    DXGroup      VARCHAR(30)      NOT NULL,
    Created      TIMESTAMP,
    CreatedBy    USERID,
    Modified     TIMESTAMP,
    ModifiedBy   USERID,
    diCreated    TIMESTAMP         NULL,
    diModified   TIMESTAMP         NULL,
    diCreatedBy  USERID       NULL,
    diModifiedBy USERID       NULL,
    Container    ENTITYID     NOT NULL,
    objectid     ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_ValidDXGroup PRIMARY KEY (DXGroup)
);

CREATE TABLE snprc_ehr.ValidDXList
(
    DXGroup      VARCHAR(30)      NOT NULL,
    DX VARCHAR(30) NOT NULL,
    Created      TIMESTAMP,
    CreatedBy    USERID,
    Modified     TIMESTAMP,
    ModifiedBy   USERID,
    diCreated    TIMESTAMP         NULL,
    diModified   TIMESTAMP         NULL,
    diCreatedBy  USERID       NULL,
    diModifiedBy USERID       NULL,
    Container    ENTITYID     NOT NULL,
    objectid     ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_ValidDXList PRIMARY KEY (DXGroup, DX)
);

CREATE TABLE snprc_ehr.ValidVaccines
(
    Vaccine      VARCHAR(128)      NOT NULL,
    Created      TIMESTAMP,
    CreatedBy    USERID,
    Modified     TIMESTAMP,
    ModifiedBy   USERID,
    diCreated    TIMESTAMP         NULL,
    diModified   TIMESTAMP         NULL,
    diCreatedBy  USERID       NULL,
    diModifiedBy USERID       NULL,
    Container    ENTITYID     NOT NULL,
    objectid     ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_ValidVaccine PRIMARY KEY (Vaccine)
);

CREATE TABLE snprc_ehr.NewAnimalData
(
    Id                     VARCHAR(32)     NOT NULL,
    BirthDate              TIMESTAMP         NULL,
    BirthCode              INT              NULL,
    AcquisitionType        INT              NULL,
    AcqDate                TIMESTAMP         NULL,
    SourceInstitutionLocation   VARCHAR(10) NULL,
    Gender                 VARCHAR(10)     NULL,
    Sire                   VARCHAR(32)     NULL,
    Dam                    VARCHAR(32)     NULL,
    Species                VARCHAR(3)      NULL,
    Colony                 INT              NULL,
    AnimalAccount          VARCHAR(16)     NULL,
    OwnerInstitution       INT              NULL,
    ResponsibleInstitution INT              NULL,
    Room                   INT              NULL,
    Cage                   INT              NULL,
    Diet                   VARCHAR(20)     NULL,
    Pedigree               INT              NULL,
    IACUC                  VARCHAR(200)    NULL,
    Created                TIMESTAMP         NULL,
    CreatedBy              USERID       NULL,
    Modified               TIMESTAMP         NULL,
    ModifiedBy             USERID       NULL,
    Container              ENTITYID     NOT NULL,
    objectid               ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);

CREATE TABLE snprc_ehr.BehaviorNotificationComment
(
    NotificationNumber   INT              NOT NULL,
    NotificationDateTm   TIMESTAMP         NOT NULL,
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
    Created              TIMESTAMP         NULL,
    CreatedBy            USERID           NULL,
    ModifiedBy           USERID           NULL,
    Modified             TIMESTAMP         NULL,
    DiCreatedBy          USERID           NULL,
    DiCreated            TIMESTAMP         NULL,
    DiModifiedBy         USERID           NULL,
    DiModified           TIMESTAMP         NULL,
    tid                  SERIAL           NOT NULL,
    objectid             ENTITYID NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_BehaviorNotiComment_oid PRIMARY KEY (tid)
);

CREATE TABLE snprc_ehr.validDefaultIACUC
(
    WorkingIacuc VARCHAR(7)       NOT NULL,
    ArcNumSeq    INT              NOT NULL,
    ArcNumGenus VARCHAR(2)       NOT NULL,
    Mandatory    VARCHAR(1)       NULL,
    DefaultIacuc VARCHAR(1)       NULL,
    Container    ENTITYID         NOT NULL,
    Created      TIMESTAMP         NULL,
    CreatedBy    USERID           NULL,
    ModifiedBy   USERID           NULL,
    Modified     TIMESTAMP         NULL,
    DiCreatedBy  USERID           NULL,
    DiCreated    TIMESTAMP         NULL,
    DiModifiedBy USERID           NULL,
    DiModified   TIMESTAMP         NULL,
    ObjectId     ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_ValidDefaultIACUC PRIMARY KEY (WorkingIacuc)
);

CREATE TABLE snprc_ehr.Counters
(
    RowId                  SERIAL NOT NULL,
    Name                   VARCHAR(255)    NOT NULL,
    Value                  INT              NOT NULL,
    Container              ENTITYID     NOT NULL,
    ObjectId               ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    CONSTRAINT PK_snprc_Counters PRIMARY KEY (RowId),
    CONSTRAINT FK_Counters_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_container_NameValue ON snprc_ehr.Counters (Container, Name, Value);

CREATE TABLE snprc_ehr.IacucAssignmentStats
(
    ThreeYearPeriod    INT              NOT NULL,
    WorkingIacuc       VARCHAR(50)     NOT NULL,
    ArcNumSeq          INT              NOT NULL,
    arcNumGenus        VARCHAR(50)      NOT NULL,
    FirstAmendment     INT              NOT NULL,
    LastAmendment      INT              NOT NULL,
    StartDate          TIMESTAMP         NOT NULL,
    EndDate            TIMESTAMP         NULL,
    NumAnimalsAllowed  INT              NOT NULL,
    NumAnimalsAssigned INT              NOT NULL,
    diCreated          TIMESTAMP,
    diModified         TIMESTAMP,
    diCreatedBy        USERID,
    diModifiedBy       USERID,
    Container          ENTITYID         NOT NULL,

    CONSTRAINT PK_IacucAssignmentStats PRIMARY KEY ( WorkingIacuc, ThreeYearPeriod ),
    CONSTRAINT FK_IacucAssignmentsStats_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_ehr.ExternalReports
(
    Id                 SERIAL NOT NULL,
    SortOrder          INT              NULL,
    Label              VARCHAR(64)     NOT NULL,
    Report             VARCHAR(400)    NOT NULL,
    Description        VARCHAR(4000)   NOT NULL,
    Parameters         VARCHAR(4000)   NULL,
    rsParameters       VARCHAR(4000)   NULL,
    Created            TIMESTAMP         DEFAULT CURRENT_TIMESTAMP,
    Modified           TIMESTAMP         DEFAULT CURRENT_TIMESTAMP,
    CreatedBy          USERID,
    ModifiedBy         USERID,

    CONSTRAINT PK_ExternalReports PRIMARY KEY ( Id )
);

CREATE TABLE snprc_ehr.HL7_IMPORT_LOG (
    TID BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    MESSAGE_ID VARCHAR(50) NOT NULL,
    OBSERVATION_DATE_TM TIMESTAMP NULL,
    MESSAGE_CONTROL_ID VARCHAR(50) NULL,
    IMPORT_STATUS INT NOT NULL,
    RESULT_STATUS VARCHAR(10) NULL,
    PATIENT_ID VARCHAR(20) NULL,
    SPECIES VARCHAR(50) NULL,
    HL7_MESSAGE_TEXT TEXT NULL,
    IMPORT_TEXT TEXT NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_IMPORT_LOG PRIMARY KEY (TID),
    CONSTRAINT CKC_HL7_IMPORT_LOG_OBSERVATION_DATE CHECK ((OBSERVATION_DATE_TM IS NULL OR OBSERVATION_DATE_TM <= CURRENT_TIMESTAMP))
);

ALTER TABLE snprc_ehr.HL7_IMPORT_LOG ADD CONSTRAINT FK_HL7_IMPORT_LOG_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.HL7_OBX (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    OBR_OBJECT_ID ENTITYID NOT NULL,
    SET_ID VARCHAR(20) NOT NULL,
    OBR_SET_ID VARCHAR(20) NOT NULL,
    VALUE_TYPE VARCHAR(10) NULL,
    TEST_ID VARCHAR(20) NULL,
    TEST_NAME VARCHAR(50) NULL,
    serviceTestId ENTITYID NULL,
    QUALITATIVE_RESULT TEXT NULL,
    RESULT TEXT NULL,
    UNITS VARCHAR(20) NULL,
    REFERENCE_RANGE VARCHAR(60) NULL,
    ABNORMAL_FLAGS VARCHAR(10) NULL,
    RESULT_STATUS VARCHAR(10) NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_OBX PRIMARY KEY (OBJECT_ID)
);

CREATE INDEX IDX_HL7_OBX_OBR_OBJ_ID ON snprc_ehr.HL7_OBX (OBR_OBJECT_ID);
ALTER TABLE snprc_ehr.HL7_OBX ADD CONSTRAINT FK_HL7_OBX_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.HL7_NTE (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    OBR_OBJECT_ID ENTITYID NOT NULL,
    SET_ID VARCHAR(20) NOT NULL,
    OBR_SET_ID VARCHAR(20) NOT NULL,
    COMMENT TEXT NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_NTE PRIMARY KEY (OBJECT_ID)
);

ALTER TABLE snprc_ehr.HL7_NTE ADD CONSTRAINT FK_HL7_NTE_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
CREATE INDEX IDX_HL7_NTE_OBR_OBJ_ID ON snprc_ehr.HL7_NTE (OBR_OBJECT_ID);

CREATE TABLE snprc_ehr.HL7_OBR (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    MESSAGE_CONTROL_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    ANIMAL_ID VARCHAR(6) NOT NULL,
    VERIFIED_DATE_TM TIMESTAMP NULL,
    REQUESTED_DATE_TM TIMESTAMP NULL,
    OBSERVATION_DATE_TM TIMESTAMP NULL,
    SPECIMEN_RECEIVED_DATE_TM TIMESTAMP NULL,
    PV1_VISIT_NUM VARCHAR(50) NULL,
    SET_ID VARCHAR(20) NOT NULL,
    SPECIMEN_NUM VARCHAR(50) NULL,
    PROCEDURE_ID VARCHAR(20) NULL,
    PROCEDURE_NAME VARCHAR(200) NULL,
    PRIORITY VARCHAR(10) NULL,
    RESULT_STATUS VARCHAR(10) NULL,
    TECHNICIAN_FIRST_NAME VARCHAR(50) NULL,
    TECHNICIAN_LAST_NAME VARCHAR(50) NULL,
    CHARGE_ID INT NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_OBR PRIMARY KEY (OBJECT_ID),
    CONSTRAINT CKC_ENTRY_DATE_TM_HL7_OBR_OBR CHECK ((ENTRY_DATE_TM <= CURRENT_TIMESTAMP))
);

CREATE INDEX IDX_HL7_OBR_ID_DATE ON snprc_ehr.HL7_OBR (ANIMAL_ID, OBSERVATION_DATE_TM);
ALTER TABLE snprc_ehr.HL7_OBR ADD CONSTRAINT FK_HL7_OBR_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
ALTER TABLE snprc_ehr.HL7_OBX ADD CONSTRAINT FK_OBX_REF_OBR FOREIGN KEY(OBR_OBJECT_ID) REFERENCES snprc_ehr.HL7_OBR (OBJECT_ID);
ALTER TABLE snprc_ehr.HL7_NTE ADD CONSTRAINT FK_NTE_REF_OBR FOREIGN KEY(OBR_OBJECT_ID) REFERENCES snprc_ehr.HL7_OBR (OBJECT_ID);

CREATE TABLE snprc_ehr.HL7_PID (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    SET_ID VARCHAR(20) NULL,
    PATIENT_ID_EXTERNAL VARCHAR(20) NULL,
    PATIENT_ID_INTERNAL VARCHAR(20) NULL,
    BIRTHDATE TIMESTAMP NULL,
    SEX VARCHAR(20) NULL,
    BREED VARCHAR(50) NULL,
    SPECIES VARCHAR(50) NULL,
    ACCOUNT_NUMBER VARCHAR(50) NULL,
    DEATH_DATE VARCHAR(50) NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_PID PRIMARY KEY (MESSAGE_ID, IDX)
);

CREATE INDEX IDX_HL7_PID_ID ON snprc_ehr.HL7_PID (PATIENT_ID_EXTERNAL);
ALTER TABLE snprc_ehr.HL7_PID ADD CONSTRAINT FK_HL7_PID_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.HL7_PV1 (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    SET_ID VARCHAR(20) NULL,
    ADMISSION_TYPE VARCHAR(20) NULL,
    ATTENDING_DOCTOR_LAST VARCHAR(50) NULL,
    ATTENDING_DOCTOR_FIRST VARCHAR(50) NULL,
    VISIT_NUMBER VARCHAR(20) NULL,
    CHARGE_NUMBER VARCHAR(20) NULL,
    ADMIT_DATE TIMESTAMP NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_PV1 PRIMARY KEY (MESSAGE_ID, IDX)
);

ALTER TABLE snprc_ehr.HL7_PV1 ADD CONSTRAINT FK_HL7_PV1_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.HL7_ORC (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    ORDER_CONTROL_CODE VARCHAR(20) NULL,
    FILLER_ORDER_NUMBER VARCHAR(22) NULL,
    ENTERED_BY_LAST VARCHAR(50) NULL,
    ENTERED_BY_FIRST VARCHAR(50) NULL,
    VERIFIED_BY_LAST VARCHAR(50) NULL,
    VERIFIED_BY_FIRST VARCHAR(50) NULL,
    ORDER_PROVIDER_LAST VARCHAR(50) NULL,
    ORDER_PROVIDER_FIRST VARCHAR(50) NULL,
    CALLBACK_EMAIL VARCHAR(50) NULL,
    ORDER_DATE TIMESTAMP NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_ORC PRIMARY KEY (MESSAGE_ID, IDX)
);

ALTER TABLE snprc_ehr.HL7_ORC ADD CONSTRAINT FK_HL7_ORC_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.HL7_MSH (
    MESSAGE_ID VARCHAR(50) NOT NULL,
    IDX INT NOT NULL,
    SENDING_APPLICATION VARCHAR(50) NULL,
    SENDING_FACILITY VARCHAR(50) NULL,
    RECEIVING_APPLICATION VARCHAR(50) NULL,
    RECEIVING_FACILITY VARCHAR(50) NULL,
    MESSAGE_TYPE VARCHAR(50) NULL,
    TRIGGER_EVENT_ID VARCHAR(50) NULL,
    MESSAGE_CONTROL_ID VARCHAR(50) NULL,
    MESSAGE_DATE_TM TIMESTAMP NULL,
    Container ENTITYID NOT NULL,
    OBJECT_ID ENTITYID NOT NULL DEFAULT gen_random_uuid(),
    USER_NAME VARCHAR(128) NOT NULL DEFAULT CURRENT_USER,
    ENTRY_DATE_TM TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TIMESTAMP BYTEA NULL, -- SQL Server ROWVERSION mapped to BYTEA
    CONSTRAINT PK_HL7_MSH PRIMARY KEY (MESSAGE_ID)
);

ALTER TABLE snprc_ehr.HL7_MSH ADD CONSTRAINT FK_HL7_MSH_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
ALTER TABLE snprc_ehr.HL7_OBR ADD CONSTRAINT FK_OBR_REF_MSH FOREIGN KEY(MESSAGE_ID) REFERENCES snprc_ehr.HL7_MSH (MESSAGE_ID);
ALTER TABLE snprc_ehr.HL7_PID ADD CONSTRAINT FK_PID_REF_MSH FOREIGN KEY(MESSAGE_ID) REFERENCES snprc_ehr.HL7_MSH (MESSAGE_ID);
ALTER TABLE snprc_ehr.HL7_PV1 ADD CONSTRAINT FK_PV1_REF_MSH FOREIGN KEY(MESSAGE_ID) REFERENCES snprc_ehr.HL7_MSH (MESSAGE_ID);
ALTER TABLE snprc_ehr.HL7_ORC ADD CONSTRAINT FK_ORC_REF_MSH FOREIGN KEY(MESSAGE_ID) REFERENCES snprc_ehr.HL7_MSH (MESSAGE_ID);

CREATE TABLE snprc_ehr.HL7_PathologyCasesStaging (
    ID VARCHAR(32) NOT NULL,
    Date TIMESTAMP NOT NULL,
    RowId BIGSERIAL NOT NULL,
    AccessionNumber VARCHAR(10) NULL,
    AccessionCode VARCHAR(4000) NULL,
    Tissue VARCHAR(4000) NULL,
    PerformedBy VARCHAR(64) NULL,
    Description VARCHAR(4000) NULL,
    Remark VARCHAR(4000) NULL,
    ApathRecordStatus VARCHAR(1) NULL,
    DeathType VARCHAR(1) NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    ObjectId ENTITYID NULL,
    timestamp BYTEA, -- SQL Server ROWVERSION mapped to BYTEA

    CONSTRAINT PK_HL7_PathologyCasesStaging PRIMARY KEY (ID, Date)
);

CREATE TABLE snprc_ehr.HL7_PathologyDiagnosesStaging (
    ID VARCHAR(32) NOT NULL,
    Date TIMESTAMP NOT NULL,
    AccessionNumber VARCHAR(40) NULL,
    RowId BIGSERIAL NOT NULL,
    Morphology VARCHAR(4000) NULL,
    Organ VARCHAR(4000) NULL,
    EtiologyCode VARCHAR(4000) NULL,
    SpecificEtiology VARCHAR(4000) NULL,
    PerformedBy VARCHAR(64) NULL,
    Description VARCHAR(4000) NULL,
    Remark VARCHAR(4000) NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    ObjectId ENTITYID NULL,
    timestamp BYTEA, -- SQL Server ROWVERSION mapped to BYTEA

    CONSTRAINT PK_HL7_PathologyDiagnosesStaging PRIMARY KEY (RowId)
);

CREATE TABLE snprc_ehr.HL7_DeletePathologyCasesStaging (
    AccessionNumber VARCHAR(10) NOT NULL,
    ObjectId ENTITYID NOT NULL,
    timestamp BYTEA, -- SQL Server ROWVERSION mapped to BYTEA

    CONSTRAINT PK_HL7_DeletePathologyCasesStaging PRIMARY KEY (AccessionNumber, ObjectId)
);

CREATE TABLE snprc_ehr.HL7_DeletePathologyDiagnosesStaging (
    AccessionNumber VARCHAR(10) NOT NULL,
    ObjectId ENTITYID NOT NULL,
    timestamp BYTEA, -- SQL Server ROWVERSION mapped to BYTEA

    CONSTRAINT PK_HL7_DeletePathologyDiagnosesStaging PRIMARY KEY (AccessionNumber, ObjectId)
);

CREATE TABLE snprc_ehr.HL7_Demographics (
    ID VARCHAR(32) NOT NULL,
    RowId BIGSERIAL NOT NULL,
    Gender VARCHAR(32) NULL,
    Species VARCHAR(32) NOT NULL,
    Breed VARCHAR(40) NOT NULL,
    BirthDate TIMESTAMP NULL,
    DeathDate TIMESTAMP NULL,
    isDeceased VARCHAR(32) NULL,
    Dam VARCHAR(32) NULL,
    Sire VARCHAR(32) Null,
    ObjectId ENTITYID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy VARCHAR(32) NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_HL7_Demographics PRIMARY KEY (RowId)
);

CREATE TABLE snprc_ehr.SndSuperPackageStaging
(
    TopLevelPkgId INTEGER NOT NULL,
    SuperPkgId INTEGER NOT NULL,
    ParentSuperPkgId INTEGER NULL,
    PkgId INTEGER NOT NULL,
    TreePath TEXT NOT NULL,
    SuperPkgPath TEXT NOT NULL,
    SortOrder INTEGER NULL,
    Required INTEGER NULL,
    Description TEXT NOT NULL,
    Narrative TEXT NOT NULL,
    Active INTEGER NOT NULL,
    Repeatable INTEGER NOT NULL,
    Level INTEGER NOT NULL,
    Created TIMESTAMP NOT NULL,
    CreatedBy USERID NOT NULL,
    Modified TIMESTAMP NOT NULL,
    ModifiedBy USERID NOT NULL,
    diModified TIMESTAMP NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_SndSuperPackageStaging PRIMARY KEY ( TopLevelPkgId, SuperPkgId)
);

CREATE TABLE snprc_ehr.SndPackageStaging
(
    PkgId INTEGER NOT NULL,
    Description VARCHAR(4000) NOT NULL,
    Active BOOLEAN NOT NULL,
    Repeatable BOOLEAN NOT NULL,
    Narrative VARCHAR(4000) NOT NULL,
    UsdaCode VARCHAR(4000) NOT NULL,
    CreatedBy USERID NOT NULL,
    Created TIMESTAMP NOT NULL,
    ModifiedBy USERID NOT NULL,
    Modified TIMESTAMP NOT NULL,
    diModified TIMESTAMP NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_SndPackageStaging PRIMARY KEY (PkgId)
);

CREATE TABLE snprc_ehr.SndPackageAttributeStaging
(
    PkgId INTEGER NOT NULL,
    AttributeId INTEGER NOT NULL,
    AttributeName VARCHAR(128) NOT NULL,
    LookupSchema VARCHAR(128) NULL,
    LookupQuery VARCHAR(128) NULL,
    RangeURI TEXT NULL,
    Label VARCHAR(128) NOT NULL,
    ValidatorExpression VARCHAR(128) NULL,
    SortOrder INT NULL,
    Required BOOLEAN NULL,
    DefaultValue TEXT NULL,
    AlternateText TEXT NULL,
    Created TIMESTAMP NOT NULL,
    CreatedBy USERID NOT NULL,
    Modified TIMESTAMP NOT NULL,
    ModifiedBy USERID NOT NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT pk_SndPackagesAttributeStaging PRIMARY KEY (AttributeId)
);

CREATE TABLE snprc_ehr.therapy_formulary(
    RowId INT NOT NULL,
    drug VARCHAR(400) NOT NULL,
    dose NUMERIC(8, 4) NOT NULL,
    route INT NOT NULL, 
    frequency INT NOT NULL, 
    duration INT NOT NULL,
    units INT NOT NULL, 
    isActive INT NULL,
    dateDisabled TIMESTAMP NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_therapy_formulary PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.therapy_formulary ADD CONSTRAINT FK_therapy_formulary_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.therapy_frequency(
    RowId INT  NOT NULL,
    frequency VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    isActive INT NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    ObjectId ENTITYID NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_therapy_frequency  PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.therapy_frequency ADD CONSTRAINT FK_therapy_frequency FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.therapy_routes(
    RowId INT NOT NULL,
    route VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    isActive INT NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    ObjectId ENTITYID NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_therapy_routes  PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.therapy_routes ADD CONSTRAINT FK_therapy_routes FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.therapy_units(
    RowId INT NOT NULL,
    units VARCHAR(30) NOT NULL,
    description VARCHAR(100),
    isActive INT NULL,
    Container ENTITYID NOT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    ObjectId ENTITYID NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_therapy_units PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.therapy_units ADD CONSTRAINT FK_therapy_units FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

CREATE TABLE snprc_ehr.therapy_resolutions
(
    RowId      INT          NOT NULL,
    resolution VARCHAR(30)  NOT NULL,
    isActive   INT NULL,
    Container  ENTITYID NOT NULL,
    Created    TIMESTAMP NULL,
    CreatedBy  USERID NULL,
    Modified   TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    ObjectId   ENTITYID NULL DEFAULT gen_random_uuid(),

    CONSTRAINT PK_therapy_resolutions PRIMARY KEY (RowId)
);

ALTER TABLE snprc_ehr.therapy_resolutions ADD CONSTRAINT FK_therapy_resolutions FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);

/* Function to emulate T-SQL logic for checking specific numeric formatting */
CREATE OR REPLACE FUNCTION snprc_ehr.f_isNumeric(value TEXT)
RETURNS INT AS $$
DECLARE
    trimmed_value TEXT;
BEGIN
    IF value IS NULL THEN
        RETURN 0;
    END IF;

    trimmed_value := TRIM(REPLACE(value, ' ', ''));

    -- Check if it is a valid numeric using Regex
    -- This regex matches optional sign, digits, optional dot, optional digits
    IF trimmed_value ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN
        
        -- Apply the specific logic from T-SQL script:
        -- 1. If length is 1 and it contains '+' (Regex handles this mostly, but ensures '+5' is valid while '+' is not)
        -- 2. If length is 1 and it contains '-' (Same)
        -- 3. If contains ','
        -- 4. If '-' is not at the start
        
        -- The T-SQL logic specifically forbade comma, and signs in the middle
        IF (LENGTH(trimmed_value) = 1 AND trimmed_value = '+')
           OR (LENGTH(trimmed_value) = 1 AND trimmed_value = '-')
           OR (POSITION(',' IN trimmed_value) > 0)
           OR (POSITION('-' IN trimmed_value) > 1) 
        THEN
            RETURN 0;
        END IF;

RETURN 1;
END IF;

RETURN 0;
END;
$$ LANGUAGE plpgsql;
