/*
 * Copyright (c) 2020-2026 LabKey Corporation
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
    Container entityId NOT NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),
    pkgType NVARCHAR(1) not null default 'U',

    CONSTRAINT PK_packages PRIMARY KEY (id),
    CONSTRAINT FK_packages_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_package_objectid ON snprc_ehr.package (objectid);

CREATE TABLE snprc_ehr.package_category (
    id int not null,
    description NVARCHAR(MAX),
    Container entityId NOT NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_package_categories PRIMARY KEY (id),
    CONSTRAINT FK_package_categories_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_package_category_objectid ON snprc_ehr.package_category (objectid);

CREATE TABLE snprc_ehr.package_category_junction (
    rowId int not null,
    packageId int not null,
    categoryId int not null,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_package_category_junction PRIMARY KEY (rowId),
    CONSTRAINT FK_package_category_junction_packageId FOREIGN KEY (packageId) REFERENCES snprc_ehr.package(id),
    CONSTRAINT FK_package_category_junction_categoryId FOREIGN KEY (categoryId) REFERENCES snprc_ehr.package_category(id)
);
GO

CREATE UNIQUE INDEX IDX_package_category_junction ON snprc_ehr.package_category_junction(categoryId, packageId);
CREATE UNIQUE INDEX idx_package_category_junction_objectid ON snprc_ehr.package_category_junction (objectid);

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
    species_code NVARCHAR(3) NOT NULL,
    arc_species_code NVARCHAR(3) NOT NULL,
    tid INT,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    primate VARCHAR(1),
    objectid uniqueidentifier not null default newid(),
    Created DATETIME,
    Modified DATETIME,
    CreatedBy USERID,
    ModifiedBy USERID,

    CONSTRAINT pk_species PRIMARY KEY (species_code)
);

CREATE UNIQUE INDEX idx_species_objectid ON snprc_ehr.species (objectid);

CREATE TABLE snprc_ehr.clinical_observation_datasets
(
    rowId Int NOT NULL,
    dataset_name NVARCHAR(255) NOT NULL,
    category_name NVARCHAR(255) NOT NULL,
    sort_order Int NULL,
    Container entityId NOT NULL,
    objectid uniqueidentifier not null default newid(),

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
    Container entityId NOT NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT [PK_VALID_ACCOUNTS] PRIMARY KEY CLUSTERED (account ASC )
);
GO

CREATE UNIQUE INDEX idx_validAccounts_objectid ON snprc_ehr.validAccounts (objectid);

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
    ObjectId uniqueidentifier NOT NULL DEFAULT NEWID(),
    [Created] [DATETIME] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [DATETIME] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [DiCreated] [DATETIME] NULL,
    [DiModified] [DATETIME] NULL,
    [DiCreatedBy] [dbo].[USERID] NULL,
    [DiModifiedBy] [dbo].[USERID] NULL,
    Container entityId NOT NULL,

    CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (ServiceId),
    CONSTRAINT FK_snprc_labwork_services_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE UNIQUE INDEX idx_labwork_services_serviceId ON [snprc_ehr].[labwork_services](ServiceId);
GO

CREATE TABLE snprc_ehr.validInstitutions (
    institution_id integer NOT NULL ,
    institution_name varchar(200) NOT NULL,
    short_name varchar(20) NOT NULL,
    city varchar(50) NOT NULL,
    state varchar(20) NOT NULL,
    affiliate varchar(50) NULL,
    web_site varchar(200) NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    Container entityId NOT NULL,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_snprc_valid_institutions PRIMARY KEY (institution_id),
    CONSTRAINT FK_snprc_valid_institutions FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_validInstitutions_objectid ON snprc_ehr.validInstitutions (objectid);

CREATE TABLE snprc_ehr.validVets (
    vetId  integer NOT NULL,
    displayName varchar(128) NOT NULL ,
    emailAddress varchar(128) NULL,
    status varchar(10) NOT NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    Container entityId NOT NULL,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_snprc_validVets PRIMARY KEY (vetId),
    CONSTRAINT FK_snprc_validVets FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_validVets_objectid ON snprc_ehr.validVets (objectid);

CREATE TABLE snprc_ehr.valid_bd_status (
    value  integer NOT NULL,
    description varchar(128) NOT NULL ,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    Container entityId NOT NULL,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_snprc_valid_bd_status PRIMARY KEY (value),
    CONSTRAINT FK_snprc_valid_bd_status FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO
CREATE UNIQUE INDEX idx_valid_bd_status_objectid ON snprc_ehr.valid_bd_status (objectid);

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
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    Container entityId NOT NULL,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_animal_group_categories PRIMARY KEY (category_code),
    CONSTRAINT FK_animal_group_categories FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_animal_group_categories_objectid ON snprc_ehr.animal_group_categories (objectid);

CREATE TABLE snprc_ehr.animal_groups(
    code INT NOT NULL,
    category_code INT NOT NULL,
    name VARCHAR(128) NOT NULL, -- Renamed from description
    date DATE NOT NULL,
    enddate DATE NULL,
    comment VARCHAR(MAX) NULL,
    sort_order  INT NULL,
    Created DATETIME,
    CreatedBy USERID,
    Modified DATETIME,
    ModifiedBy USERID,
    diCreated DATETIME,
    diModified DATETIME,
    diCreatedBy USERID,
    diModifiedBy USERID,
    Container entityId NOT NULL,
    objectid uniqueidentifier not null default newid(),

    CONSTRAINT PK_snprc_animal_groups PRIMARY KEY (code, category_code),
    CONSTRAINT FK_snprc_animal_groups FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_animal_groups_objectid ON snprc_ehr.animal_groups (objectid);
CREATE UNIQUE INDEX idx_animal_groups_code ON snprc_ehr.animal_groups (code);

CREATE TABLE snprc_ehr.labwork_types (
    RowId [INT] IDENTITY(1,1) NOT NULL,
    ServiceType varchar(100) NOT NULL,
    ObjectId uniqueidentifier NOT NULL DEFAULT NEWID(),
    [Created] [DATETIME] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [DATETIME] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [DiCreated] [DATETIME] NULL,
    [DiModified] [DATETIME] NULL,
    [DiCreatedBy] [dbo].[USERID] NULL,
    [DiModifiedBy] [dbo].[USERID] NULL,
    Container entityId NOT NULL,

    CONSTRAINT PK_snprc_labwork_types PRIMARY KEY (ServiceType),
    CONSTRAINT FK_snprc_labwork_types_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

ALTER TABLE [snprc_ehr].[labwork_services] WITH CHECK ADD CONSTRAINT [FK_snprc_labwork_panels_dataset] FOREIGN KEY([Dataset]) REFERENCES [snprc_ehr].[labwork_types] ([ServiceType]);
GO
ALTER TABLE [snprc_ehr].[labwork_services] CHECK CONSTRAINT [FK_snprc_labwork_panels_dataset];
GO

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
    [ObjectId] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    CONSTRAINT [PK_snprc_labwork_panels] PRIMARY KEY CLUSTERED
    (
        [RowId] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

ALTER TABLE [snprc_ehr].[labwork_panels] WITH CHECK ADD CONSTRAINT [FK_snprc_labwork_panels_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

ALTER TABLE [snprc_ehr].[labwork_panels] CHECK CONSTRAINT [FK_snprc_labwork_panels_container];
GO

ALTER TABLE [snprc_ehr].[labwork_panels] WITH CHECK ADD CONSTRAINT [FK_snprc_labwork_panels_services] FOREIGN KEY([ServiceId]) REFERENCES [snprc_ehr].[labwork_services] ([ServiceId]);
GO

ALTER TABLE [snprc_ehr].[labwork_panels] CHECK CONSTRAINT [FK_snprc_labwork_panels_services];
GO

CREATE TABLE [snprc_ehr].[MhcData](
    [Id] [nvarchar](32) NOT NULL,
    [Haplotype] [nvarchar](128) NOT NULL,
    [RowId] [bigint] IDENTITY(1,1) NOT NULL,
    [OcId] [NVARCHAR](128) NULL,
    [MhcValue] [nvarchar](128) NULL,
    [DataFileSource] [nvarchar](4000) NULL,
    [ObjectId] uniqueidentifier NOT NULL DEFAULT NEWID(),
    [Created] [DATETIME] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [DATETIME] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [DiCreated] [DATETIME] NULL,
    [DiModified] [DATETIME] NULL,
    [DiCreatedBy] [dbo].[USERID] NULL,
    [DiModifiedBy] [dbo].[USERID] NULL,
    Container entityId NOT NULL

    CONSTRAINT PK_snprc_MhcData PRIMARY KEY ([RowId])
    CONSTRAINT FK_snprc_MhcData_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

go

ALTER TABLE [snprc_ehr].[MhcData] ADD CONSTRAINT [AK_ID_Haplotype] UNIQUE NONCLUSTERED
  (
    [Id] ASC,
    [Haplotype] ASC
  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO

CREATE TABLE [snprc_ehr].[ValidChargeBySpecies](
    [Project] INTEGER NOT NULL,
    [Species] NVARCHAR(2) NOT NULL,
    [Purpose] NVARCHAR (2) NOT NULL,
    [ObjectId] uniqueidentifier NOT NULL DEFAULT NEWID(),
    [Created] [DATETIME] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [DATETIME] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [DiCreated] [DATETIME] NULL,
    [DiModified] [DATETIME] NULL,
    [DiCreatedBy] [dbo].[USERID] NULL,
    [DiModifiedBy] [dbo].[USERID] NULL,
    Container entityId NOT NULL,
    startDate DATETIME NOT NULL DEFAULT GETDATE(),
    stopDate DATETIME,

    CONSTRAINT PK_snprc_ValidChargeBySpecies PRIMARY KEY CLUSTERED (Project, Species),
    CONSTRAINT FK_snprc_ValidChargeBySpecies_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
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
    Container entityId NOT NULL

    CONSTRAINT PK_snprc_fee_schedule PRIMARY KEY ([RowId]),
    CONSTRAINT FK_snprc_fee_Schedule_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_fee_schedule_objectid ON snprc_ehr.feeSchedule (objectid);
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

    CONSTRAINT [PK_FeeScheduleSpeciesLookup] PRIMARY KEY CLUSTERED ([FsSpecies], [SpeciesCode]),
    CONSTRAINT [FK_FeeScheduleSpeciesLookup_container] FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

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
    [objectid] [uniqueidentifier] NOT NULL DEFAULT NEWID(),

    CONSTRAINT [PK_LocationTemperature] PRIMARY KEY CLUSTERED ([Room] ASC,[Date] ASC),
    CONSTRAINT FK_snprc_LocationTemperature_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_snprc_LocationTemperature_objectid ON snprc_ehr.LocationTemperature (ObjectId);
CREATE INDEX idx_snprc_LocationTemperature_Date ON snprc_ehr.LocationTemperature (Date, Room);
GO

CREATE TABLE snprc_ehr.ValidDiet(
    [Diet] [nvarchar](20) NOT NULL,
    [ArcSpeciesCode] [nvarchar](2) NULL,
    [StartDate] [datetime] NOT NULL,
    [StopDate] [datetime] NULL,
    [SnomedCode] [nvarchar](7) NULL,
    [DietCode] [INTEGER] NOT NULL, -- Renamed from DietId
    [Created] DATETIME,
    [CreatedBy] USERID,
    [Modified] DATETIME,
    [ModifiedBy] USERID,
    [diCreated] [datetime] NULL,
    [diModified] [datetime] NULL,
    [diCreatedBy] [dbo].[USERID] NULL,
    [diModifiedBy] [dbo].[USERID] NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [objectid] [uniqueidentifier] NOT NULL DEFAULT NEWID(),

    CONSTRAINT [PK_ValidDiet] PRIMARY KEY CLUSTERED (Diet) -- Changed primary key
);

CREATE UNIQUE INDEX idx_ValidDiet_SnomedCode_StartStopDate ON snprc_ehr.ValidDiet(SnomedCode, StartDate, StopDate);
go

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
    objectid     uniqueidentifier NOT NULL DEFAULT NEWID(),

    CONSTRAINT PK_ValidDXGroup PRIMARY KEY CLUSTERED (DXGroup ASC)
);

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
    objectid     uniqueidentifier NOT NULL DEFAULT NEWID(),

    CONSTRAINT PK_ValidDXList PRIMARY KEY CLUSTERED (DXGroup ASC, DX ASC)
);

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
    objectid     uniqueidentifier NOT NULL DEFAULT NEWID(),

    CONSTRAINT PK_ValidVaccine PRIMARY KEY CLUSTERED (Vaccine ASC)
);

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
    objectid               uniqueidentifier NOT NULL DEFAULT NEWID(),

    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);

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
    objectid             UNIQUEIDENTIFIER NULL DEFAULT NEWID(),

    CONSTRAINT PK_BehaviorNotiComment_oid PRIMARY KEY (tid)
);

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
    ObjectId     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),

    CONSTRAINT PK_ValidDefaultIACUC PRIMARY KEY (WorkingIacuc)
);

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
    Container          entityId         NOT NULL,

    CONSTRAINT PK_IacucAssignmentStats PRIMARY KEY CLUSTERED ( WorkingIacuc ASC, ThreeYearPeriod ASC ),
    CONSTRAINT FK_IacucAssignmentsStats_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

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
    ModifiedBy         USERID,

    CONSTRAINT PK_ExternalReports PRIMARY KEY CLUSTERED ( Id ASC)
);

CREATE TABLE [snprc_ehr].[HL7_IMPORT_LOG](
    [TID] [NUMERIC](18, 0) IDENTITY(1,1) NOT NULL,
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [OBSERVATION_DATE_TM] [DATETIME] NULL,
    [MESSAGE_CONTROL_ID] [VARCHAR](50) NULL,
    [IMPORT_STATUS] [INT] NOT NULL,
    [RESULT_STATUS] [VARCHAR](10) NULL,
    [PATIENT_ID] [VARCHAR](20) NULL,
    [SPECIES] [VARCHAR](50) NULL,
    [HL7_MESSAGE_TEXT] [VARCHAR](MAX) NULL,
    [IMPORT_TEXT] [VARCHAR](MAX) NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_IMPORT_LOG] PRIMARY KEY CLUSTERED
(
[TID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [CKC_HL7_IMPORT_LOG_OBSERVATION_DATE] CHECK  (([OBSERVATION_DATE_TM] IS NULL OR [OBSERVATION_DATE_TM]<=GETDATE()))
    );
GO

ALTER TABLE [snprc_ehr].[HL7_IMPORT_LOG] WITH CHECK ADD CONSTRAINT [FK_HL7_IMPORT_LOG_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE TABLE [snprc_ehr].[HL7_OBX](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [OBR_OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL,
    [SET_ID] [VARCHAR](20) NOT NULL,
    [OBR_SET_ID] [VARCHAR](20) NOT NULL,
    [VALUE_TYPE] [VARCHAR](10) NULL,
    [TEST_ID] [VARCHAR](20) NULL,
    [TEST_NAME] [VARCHAR](50) NULL,
    [serviceTestId] [UNIQUEIDENTIFIER] NULL,
    [QUALITATIVE_RESULT] [VARCHAR](MAX) NULL,
    [RESULT] [VARCHAR](MAX) NULL,
    [UNITS] [VARCHAR](20) NULL,
    [REFERENCE_RANGE] [VARCHAR](60) NULL,
    [ABNORMAL_FLAGS] [VARCHAR](10) NULL,
    [RESULT_STATUS] [VARCHAR](10) NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_OBX] PRIMARY KEY CLUSTERED
(
    [OBJECT_ID]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE NONCLUSTERED INDEX [IDX_HL7_OBX_OBR_OBJ_ID] ON [snprc_ehr].[HL7_OBX]
(
    [OBR_OBJECT_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

ALTER TABLE [snprc_ehr].[HL7_OBX] WITH CHECK ADD CONSTRAINT [FK_HL7_OBX_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE TABLE [snprc_ehr].[HL7_NTE](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [OBR_OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL,
    [SET_ID] [VARCHAR](20) NOT NULL,
    [OBR_SET_ID] [VARCHAR](20) NOT NULL,
    [COMMENT] [VARCHAR](MAX) NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_NTE] PRIMARY KEY CLUSTERED
(
    [OBJECT_ID] ASC

) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

ALTER TABLE [snprc_ehr].[HL7_NTE] WITH CHECK ADD CONSTRAINT [FK_HL7_NTE_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE NONCLUSTERED INDEX [IDX_HL7_NTE_OBR_OBJ_ID] ON [snprc_ehr].[HL7_NTE]
(
    [OBR_OBJECT_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

CREATE TABLE [snprc_ehr].[HL7_OBR](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [MESSAGE_CONTROL_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [ANIMAL_ID] [VARCHAR](6) NOT NULL,
    [VERIFIED_DATE_TM] [DATETIME] NULL,
    [REQUESTED_DATE_TM] [DATETIME] NULL,
    [OBSERVATION_DATE_TM] [DATETIME] NULL,
    [SPECIMEN_RECEIVED_DATE_TM] [DATETIME] NULL,
    [PV1_VISIT_NUM] [VARCHAR](50) NULL,
    [SET_ID] [VARCHAR](20) NOT NULL,
    [SPECIMEN_NUM] [VARCHAR](50) NULL,
    [PROCEDURE_ID] [VARCHAR](20) NULL,
    [PROCEDURE_NAME] [VARCHAR](200) NULL, -- Increased size from VARCHAR(50)
    [PRIORITY] [VARCHAR](10) NULL,
    [RESULT_STATUS] [VARCHAR](10) NULL,
    [TECHNICIAN_FIRST_NAME] [VARCHAR](50) NULL,
    [TECHNICIAN_LAST_NAME] [VARCHAR](50) NULL,
    [CHARGE_ID] [INT] NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_OBR] PRIMARY KEY CLUSTERED
(
    [OBJECT_ID]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [CKC_ENTRY_DATE_TM_HL7_OBR_OBR] CHECK  (([ENTRY_DATE_TM]<=GETDATE()))
);
GO

CREATE NONCLUSTERED INDEX [IDX_HL7_OBR_ID_DATE] ON [snprc_ehr].[HL7_OBR]
(
    [ANIMAL_ID] ASC,
    [OBSERVATION_DATE_TM] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

ALTER TABLE [snprc_ehr].[HL7_OBR] WITH CHECK ADD CONSTRAINT [FK_HL7_OBR_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

ALTER TABLE [snprc_ehr].[HL7_OBX] WITH CHECK ADD CONSTRAINT [FK_OBX_REF_OBR] FOREIGN KEY([OBR_OBJECT_ID]) REFERENCES [snprc_ehr].[HL7_OBR] ([OBJECT_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_OBX] CHECK CONSTRAINT [FK_OBX_REF_OBR];
GO

ALTER TABLE [snprc_ehr].[HL7_NTE] WITH CHECK ADD CONSTRAINT [FK_NTE_REF_OBR] FOREIGN KEY([OBR_OBJECT_ID]) REFERENCES [snprc_ehr].[HL7_OBR] ([OBJECT_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_NTE] CHECK CONSTRAINT [FK_NTE_REF_OBR];
GO

CREATE TABLE [snprc_ehr].[HL7_PID](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [SET_ID] [VARCHAR](20) NULL, -- F1_C1
    [PATIENT_ID_EXTERNAL] [VARCHAR](20) NULL, -- F2_C1
    [PATIENT_ID_INTERNAL] [VARCHAR](20) NULL, -- F3_C1
    [BIRTHDATE] [DATETIME] NULL, --F7_C1
    [SEX] [VARCHAR] (20) NULL, -- F8_C1
    [BREED] [VARCHAR] (50) NULL,  -- arc_species_code - F10_C1 (Race)
    [SPECIES] [VARCHAR] (50) NULL, -- common name - F22_C1 (Ethnic Group)
    [ACCOUNT_NUMBER] [VARCHAR] (50) NULL, --F18_C1
    [DEATH_DATE] [VARCHAR] (50) NULL, -- F29_C1
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_PID] PRIMARY KEY CLUSTERED
(
    [MESSAGE_ID] ASC,
    [IDX]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    );
GO

CREATE NONCLUSTERED INDEX [IDX_HL7_PID_ID] ON [snprc_ehr].[HL7_PID]
(
    [PATIENT_ID_EXTERNAL] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

ALTER TABLE [snprc_ehr].[HL7_PID] WITH CHECK ADD CONSTRAINT [FK_HL7_PID_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE TABLE [snprc_ehr].[HL7_PV1](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [SET_ID] [VARCHAR](20) NULL, -- F1_C1
    [ADMISSION_TYPE] [VARCHAR] (20) NULL, --F4_C1
    [ATTENDING_DOCTOR_LAST] [VARCHAR] (50) NULL, -- F7_C2
    [ATTENDING_DOCTOR_FIRST] [VARCHAR] (50) NULL, -- F7_C3
    [VISIT_NUMBER] [VARCHAR] (20) NULL, -- F19_C1
    [CHARGE_NUMBER] [VARCHAR] (20) NULL, -- F22_C1 (Courtesy Code)
    [ADMIT_DATE] [DATETIME] NULL, --F44_C1
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_PV1] PRIMARY KEY CLUSTERED
(
    [MESSAGE_ID] ASC,
    [IDX]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    );
GO

ALTER TABLE [snprc_ehr].[HL7_PV1] WITH CHECK ADD CONSTRAINT [FK_HL7_PV1_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE TABLE [snprc_ehr].[HL7_ORC](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [ORDER_CONTROL_CODE] [VARCHAR](20) NULL, -- F1_C1
    [FILLER_ORDER_NUMBER] [VARCHAR] (22) NULL, --F3_C1
    [ENTERED_BY_LAST] [VARCHAR] (50) NULL, -- F10_C2
    [ENTERED_BY_FIRST] [VARCHAR] (50) NULL, -- F10_C3
    [VERIFIED_BY_LAST] [VARCHAR] (50) NULL, -- F11_C2
    [VERIFIED_BY_FIRST] [VARCHAR] (50) NULL, -- F11_C3
    [ORDER_PROVIDER_LAST] [VARCHAR] (50) NULL, -- F12_C2
    [ORDER_PROVIDER_FIRST] [VARCHAR] (50) NULL, -- F12_C3
    [CALLBACK_EMAIL] [VARCHAR](50) NULL, -- F14_C3
    [ORDER_DATE] [DATETIME] NULL, -- F15_C1
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_ORC] PRIMARY KEY CLUSTERED
(
    [MESSAGE_ID] ASC,
    [IDX]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    );
GO

ALTER TABLE [snprc_ehr].[HL7_ORC] WITH CHECK ADD CONSTRAINT [FK_HL7_ORC_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

CREATE TABLE [snprc_ehr].[HL7_MSH](
    [MESSAGE_ID] [VARCHAR](50) NOT NULL,
    [IDX] [INT] NOT NULL,
    [SENDING_APPLICATION] [VARCHAR](50) NULL,
    [SENDING_FACILITY] [VARCHAR](50) NULL,
    [RECEIVING_APPLICATION] [VARCHAR](50) NULL,
    [RECEIVING_FACILITY] [VARCHAR](50) NULL,
    [MESSAGE_TYPE] [VARCHAR](50) NULL, -- MSH_F9_C1
    [TRIGGER_EVENT_ID][VARCHAR](50) NULL, -- MSH_F9_C2
    [MESSAGE_CONTROL_ID] [VARCHAR](50) NULL,
    [MESSAGE_DATE_TM] [DATETIME] NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [OBJECT_ID] [UNIQUEIDENTIFIER] NOT NULL DEFAULT NEWID(),
    [USER_NAME] [VARCHAR](128) NOT NULL DEFAULT USER_NAME(),
    [ENTRY_DATE_TM] [DATETIME] NOT NULL DEFAULT GETDATE(),
    [TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT [PK_HL7_MSH] PRIMARY KEY CLUSTERED
(
    [MESSAGE_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    );
GO

ALTER TABLE [snprc_ehr].[HL7_MSH] WITH CHECK ADD CONSTRAINT [FK_HL7_MSH_container] FOREIGN KEY([Container]) REFERENCES [core].[Containers] ([EntityId]);
GO

ALTER TABLE [snprc_ehr].[HL7_OBR] WITH CHECK ADD CONSTRAINT [FK_OBR_REF_MSH] FOREIGN KEY([MESSAGE_ID]) REFERENCES [snprc_ehr].[HL7_MSH] ([MESSAGE_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_OBR] CHECK CONSTRAINT [FK_OBR_REF_MSH];
GO

ALTER TABLE [snprc_ehr].[HL7_PID] WITH CHECK ADD CONSTRAINT [FK_PID_REF_MSH] FOREIGN KEY([MESSAGE_ID]) REFERENCES [snprc_ehr].[HL7_MSH] ([MESSAGE_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_PID] CHECK CONSTRAINT [FK_PID_REF_MSH];
GO

ALTER TABLE [snprc_ehr].[HL7_PV1] WITH CHECK ADD CONSTRAINT [FK_PV1_REF_MSH] FOREIGN KEY([MESSAGE_ID]) REFERENCES [snprc_ehr].[HL7_MSH] ([MESSAGE_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_PV1] CHECK CONSTRAINT [FK_PV1_REF_MSH];
GO

ALTER TABLE [snprc_ehr].[HL7_ORC] WITH CHECK ADD CONSTRAINT [FK_ORC_REF_MSH] FOREIGN KEY([MESSAGE_ID]) REFERENCES [snprc_ehr].[HL7_MSH] ([MESSAGE_ID]);
GO

ALTER TABLE [snprc_ehr].[HL7_ORC] CHECK CONSTRAINT [FK_ORC_REF_MSH];
GO

CREATE TABLE snprc_ehr.HL7_PathologyCasesStaging (
    ID NVARCHAR(32) NOT NULL,
    Date DATETIME NOT NULL,
    RowId BIGINT IDENTITY(1,1) NOT NULL,
    AccessionNumber NVARCHAR(10) NULL,
    AccessionCode NVARCHAR(4000) NULL,
    Tissue NVARCHAR(4000) NULL,
    PerformedBy NVARCHAR(64) NULL,
    Description NVARCHAR(4000) NULL,
    Remark NVARCHAR(4000) NULL,
    ApathRecordStatus NVARCHAR(1) NULL,
    DeathType NVARCHAR(1) NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified datetime NULL,
    ModifiedBy dbo.USERID NULL,
    Container dbo.ENTITYID NOT NULL,
    ObjectId uniqueidentifier NULL,
    timestamp ROWVERSION,

    CONSTRAINT PK_HL7_PathologyCasesStaging PRIMARY KEY CLUSTERED
    (
        ID ASC,
        Date ASC
    ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE TABLE snprc_ehr.HL7_PathologyDiagnosesStaging (
    ID NVARCHAR(32) NOT NULL,
    Date DATETIME NOT NULL,
    AccessionNumber NVARCHAR(40) NULL,
    RowId BIGINT IDENTITY(1,1) NOT NULL,
    Morphology NVARCHAR(4000) NULL,
    Organ NVARCHAR(4000) NULL,
    EtiologyCode NVARCHAR(4000) NULL,
    SpecificEtiology NVARCHAR(4000) NULL,
    PerformedBy NVARCHAR(64) NULL,
    Description NVARCHAR(4000) NULL,
    Remark NVARCHAR(4000) NULL,
    Created datetime NULL,
    CreatedBy dbo.USERID NULL,
    Modified datetime NULL,
    ModifiedBy dbo.USERID NULL,
    Container dbo.ENTITYID NOT NULL,
    ObjectId uniqueidentifier NULL,
    timestamp ROWVERSION,

    CONSTRAINT PK_HL7_PathologyDiagnosesStaging PRIMARY KEY CLUSTERED
    (
        RowID ASC
    ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE TABLE snprc_ehr.HL7_DeletePathologyCasesStaging (
    AccessionNumber NVARCHAR(10) NOT NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL,
    timestamp ROWVERSION

    CONSTRAINT PK_HL7_DeletePathologyCasesStaging PRIMARY KEY CLUSTERED
    (
        AccessionNumber ASC,
        ObjectId ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE TABLE snprc_ehr.HL7_DeletePathologyDiagnosesStaging (
    AccessionNumber NVARCHAR(10) NOT NULL,
    ObjectId uniqueidentifier NOT NULL,
    timestamp ROWVERSION

    CONSTRAINT PK_HL7_DeletePathologyDiagnosesStaging PRIMARY KEY CLUSTERED
    (
        AccessionNumber ASC,
        ObjectId ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE TABLE snprc_ehr.HL7_Demographics (
    ID NVARCHAR(32) NOT NULL,
    RowId BIGINT IDENTITY(1,1) NOT NULL,
    Gender NVARCHAR(32) NULL,
    Species NVARCHAR(32) NOT NULL,
    Breed NVARCHAR(40) NOT NULL,
    BirthDate DATETIME NULL,
    DeathDate DATETIME NULL,
    isDeceased NVARCHAR(32) NULL,
    Dam NVARCHAR(32) NULL,
    Sire NVARCHAR(32) Null,
    ObjectId uniqueidentifier NULL,
    Modified datetime NULL,
    ModifiedBy NVARCHAR(32) NULL,
    Container dbo.ENTITYID NOT NULL,

    CONSTRAINT PK_HL7_Demographics PRIMARY KEY CLUSTERED
    (
        RowId ASC
    ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

CREATE TABLE snprc_ehr.SndSuperPackageStaging
(
    TopLevelPkgId INTEGER NOT NULL,
    SuperPkgId INTEGER NOT NULL,
    ParentSuperPkgId INTEGER NULL,
    PkgId INTEGER NOT NULL,
    TreePath VARCHAR(MAX) NOT NULL,
    SuperPkgPath VARCHAR(MAX) NOT NULL,
    SortOrder INTEGER NULL,
    Required INTEGER NULL,
    Description VARCHAR(MAX) NOT NULL,
    Narrative VARCHAR(MAX) NOT NULL,
    Active INTEGER NOT NULL,
    Repeatable INTEGER NOT NULL,
    Level INTEGER NOT NULL,
    Created DATETIME NOT NULL,
    CreatedBy USERID NOT NULL,
    Modified DATETIME NOT NULL,
    ModifiedBy USERID NOT NULL,
    diModified DATETIME NOT NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()

    CONSTRAINT PK_SndSuperPackageStaging PRIMARY KEY CLUSTERED ( TopLevelPkgId, SuperPkgId)
);
GO

CREATE TABLE snprc_ehr.SndPackageStaging
(
    PkgId INTEGER NOT NULL,
    Description NVARCHAR(4000) NOT NULL,
    Active BIT NOT NULL,
    Repeatable BIT NOT NULL,
    Narrative NVARCHAR(4000) NOT NULL,
    UsdaCode NVARCHAR(4000) NOT NULL,
    CreatedBy USERID NOT NULL,
    Created DATETIME NOT NULL,
    ModifiedBy USERID NOT NULL,
    Modified DATETIME NOT NULL,
    diModified DATETIME NOT NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()

    CONSTRAINT PK_SndPackageStaging PRIMARY KEY CLUSTERED (PkgId)
);
GO

CREATE TABLE snprc_ehr.SndPackageAttributeStaging
(
    PkgId INTEGER NOT NULL,
    AttributeId INTEGER NOT NULL,
    AttributeName VARCHAR(128) NOT NULL,
    LookupSchema VARCHAR(128) NULL,
    LookupQuery VARCHAR(128) NULL,
    RangeURI VARCHAR(MAX) NULL,
    Label VARCHAR(128) NOT NULL,
    ValidatorExpression VARCHAR(128) NULL,
    SortOrder INT NULL,
    Required BIT NULL,
    DefaultValue VARCHAR(MAX) NULL,
    AlternateText VARCHAR(MAX) NULL,
    Created DATETIME NOT NULL,
    CreatedBy USERID NOT NULL,
    Modified DATETIME NOT NULL,
    ModifiedBy USERID NOT NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()

    CONSTRAINT pk_SndPackagesAttributeStaging PRIMARY KEY CLUSTERED (AttributeId)
);
GO

CREATE TABLE snprc_ehr.therapy_formulary(
    RowId INT NOT NULL,
    drug VARCHAR(400) NOT NULL,
    dose NUMERIC(8, 4) NOT NULL,
    route INT NOT NULL, -- FK snprc_ehr.therapy_routes.RowId
    frequency INT NOT NULL, -- FK snprc_ehr.therapy_frequency.RowId`
    duration INT NOT NULL,
    units INT NOT NULL, -- FK snprc_ehr.therapy_units.RowId
    isActive INT NULL,
    dateDisabled DATETIME NULL,
    Container dbo.ENTITYID NOT NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()

    CONSTRAINT PK_therapy_formulary PRIMARY KEY CLUSTERED (RowId)
);

ALTER TABLE snprc_ehr.therapy_formulary WITH CHECK ADD CONSTRAINT FK_therapy_formulary_container FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
GO

CREATE TABLE snprc_ehr.therapy_frequency(
    RowId INT  NOT NULL,
    frequency VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    isActive INT NULL,
    Container dbo.ENTITYID NOT NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()

    CONSTRAINT PK_therapy_frequency  PRIMARY KEY CLUSTERED (RowId)
);

ALTER TABLE snprc_ehr.therapy_frequency WITH CHECK ADD CONSTRAINT FK_therapy_frequency FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
GO

CREATE TABLE snprc_ehr.therapy_routes(
    RowId INT NOT NULL,
    route VARCHAR(30) NOT NULL,
    description VARCHAR(100) NULL,
    isActive INT NULL,
    Container dbo.ENTITYID NOT NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    ObjectId UNIQUEIDENTIFIER NULL DEFAULT NEWID()

    CONSTRAINT PK_therapy_routes  PRIMARY KEY CLUSTERED (RowId)
);

ALTER TABLE snprc_ehr.therapy_routes WITH CHECK ADD CONSTRAINT FK_therapy_routes FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
GO

CREATE TABLE snprc_ehr.therapy_units(
    RowId INT NOT NULL,
    units VARCHAR(30) NOT NULL,
    description VARCHAR(100),
    isActive INT NULL,
    Container dbo.ENTITYID NOT NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    ObjectId UNIQUEIDENTIFIER NULL DEFAULT NEWID()

    CONSTRAINT PK_therapy_units PRIMARY KEY CLUSTERED (RowId)
);

ALTER TABLE snprc_ehr.therapy_units WITH CHECK ADD CONSTRAINT FK_therapy_units FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
GO

CREATE TABLE snprc_ehr.therapy_resolutions
(
    RowId      INT          NOT NULL,
    resolution VARCHAR(30)  NOT NULL,
    isActive   INT NULL,
    Container  dbo.ENTITYID NOT NULL,
    Created    DATETIME NULL,
    CreatedBy  dbo.USERID NULL,
    Modified   DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    ObjectId   UNIQUEIDENTIFIER NULL DEFAULT NEWID(),

    CONSTRAINT PK_therapy_resolutions PRIMARY KEY CLUSTERED (RowId)
);

ALTER TABLE snprc_ehr.therapy_resolutions WITH CHECK ADD CONSTRAINT FK_therapy_resolutions FOREIGN KEY(Container) REFERENCES core.Containers (EntityId);
GO

CREATE FUNCTION [snprc_ehr].[f_isNumeric]
(
    @value VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @return INT

    IF (@value IS NULL)
    BEGIN
            SET @return = 0
            GOTO finis
    END

    select @value =  LTRIM(RTRIM(REPLACE(@value, ' ', '')))

    IF (ISNUMERIC(@value) = 1)
    BEGIN
            if ( LEN(@value) = 1 AND  CHARINDEX ('+', @value, 1) > 0)
            OR ( LEN(@value) = 1 AND CHARINDEX('-', @value, 1) > 0)
            OR (CHARINDEX(',', @value, 1) > 0)
            OR (CHARINDEX('-' , @value, 2) > 1)

            BEGIN
                        SET @return = 0
                        GOTO finis
            END

            SET @return = 1
            GOTO finis

    END
        SET @return = 0

    finis:
        RETURN @return

END

GO
