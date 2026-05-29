/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists @objname = 'SndSuperPackageStaging', @objschema = 'snprc_ehr', @objtype = 'TABLE';

CREATE TABLE snprc_ehr.SndSuperPackageStaging
(
    TopLevelPkgId INTEGER NOT NULL,
    SuperPkgId INTEGER NOT NULL,
    ParentSuperPkgId INTEGER NULL,
    PkgId INTEGER NOT NULL,
    TreePath VARCHAR(800) NOT NULL,
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
    ObjectId UNIQUEIDENTIFIER NOT NULL

    CONSTRAINT PK_SndSuperPackageStaging PRIMARY KEY CLUSTERED ( TopLevelPkgId, SuperPkgId, TreePath)
);
GO