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

CREATE TABLE snprc_r24.Biomarkers (
    RowId BIGSERIAL NOT NULL,
    SampleId VARCHAR(32) NOT NULL,
    Lab VARCHAR(128) NULL,
    Analyte VARCHAR(128) NOT NULL,
    ObjectId ENTITYID DEFAULT NULL,
    Value NUMERIC(6,2),
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT PK_snprc_r24_Biomarkers PRIMARY KEY (SampleId, Analyte),
    CONSTRAINT FK_snprc_r24_Biomarkers_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_r24.SampleInventory (
    RowId BIGSERIAL NOT NULL,
    AnimalId VARCHAR(32) NOT NULL,
    Date TIMESTAMP NOT NULL,
    SampleId VARCHAR(32) NOT NULL,
    Aim VARCHAR(128) NULL,
    SampleType VARCHAR(128) NOT NULL,
    ObjectId ENTITYID DEFAULT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,
    SampleWeight NUMERIC(7,2) NULL,
    SampleAmount NUMERIC(7,2) NULL,

    CONSTRAINT pk_snprc_r24_sampleinventory PRIMARY KEY (SampleId),
    CONSTRAINT fk_snprc_r24_sampleinventory_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE snprc_r24.lookupSets (
    RowId BIGSERIAL NOT NULL,
    SetName VARCHAR(32) NOT NULL,
    Label VARCHAR(32) NOT NULL,
    ObjectId ENTITYID DEFAULT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT pk_snprc_r24_lookupsets PRIMARY KEY (RowId),
    CONSTRAINT fk_snprc_r24_lookupsets_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_r24_lookupSets_setname ON snprc_r24.lookupSets (SetName);

CREATE TABLE snprc_r24.lookups (
    RowId BIGSERIAL NOT NULL,
    SetName VARCHAR(32) NOT NULL,
    Value VARCHAR(128) NOT NULL,
    SortOrder INTEGER NULL,
    DateDisabled TIMESTAMP NULL,
    ObjectId ENTITYID DEFAULT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    DiCreated TIMESTAMP NULL,
    DiModified TIMESTAMP NULL,
    DiCreatedBy USERID NULL,
    DiModifiedBy USERID NULL,
    Container ENTITYID NOT NULL,

    CONSTRAINT pk_snprc_r24_lookups PRIMARY KEY (RowId),
    CONSTRAINT fk_snprc_r24_lookups_SetName FOREIGN KEY (SetName) REFERENCES snprc_r24.lookupSets (SetName),
    CONSTRAINT fk_snprc_r24_lookups_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

CREATE UNIQUE INDEX idx_snprc_r24_lookups_setname ON snprc_r24.lookups (SetName, Value);

CREATE TABLE snprc_r24.RowsToDelete (
    ObjectId ENTITYID NOT NULL,
    Modified TIMESTAMP NOT NULL,

    CONSTRAINT pk_snprc_r24_RowsToDelete PRIMARY KEY (ObjectId)
);

CREATE TABLE snprc_r24.WeightStaging (
    AnimalId VARCHAR(32) NOT NULL,
    Date TIMESTAMP NOT NULL,
    Weight DOUBLE PRECISION NOT NULL,
    ObjectId ENTITYID NOT NULL,
    Created TIMESTAMP NULL,
    CreatedBy USERID NULL,
    Modified TIMESTAMP NULL,
    ModifiedBy USERID NULL,

    CONSTRAINT pk_snprc_r24_weight_staging PRIMARY KEY (ObjectId)
);
