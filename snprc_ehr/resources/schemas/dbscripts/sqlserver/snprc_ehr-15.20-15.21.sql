/*
 * Copyright (c) 2015-2018 LabKey Corporation
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
