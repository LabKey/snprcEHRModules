EXEC core.fn_dropifexists 'SndSuperPackageStaging', 'snprc_ehr', 'TABLE';
GO

EXEC core.fn_dropifexists 'SndPackageStaging', 'snprc_ehr', 'TABLE';
GO

EXEC core.fn_dropifexists 'SndPackageAttributeStaging', 'snprc_ehr', 'TABLE';
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
    ObjectId UNIQUEIDENTIFIER NOT NULL

    CONSTRAINT PK_SndSuperPackageStaging
        PRIMARY KEY CLUSTERED ( TopLevelPkgId, SuperPkgId)
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
    ObjectId UNIQUEIDENTIFIER NOT NULL

    CONSTRAINT PK_SndPackageStaging
        PRIMARY KEY CLUSTERED (PkgId)
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
    ObjectId UNIQUEIDENTIFIER NOT NULL

    CONSTRAINT pk_SndPackagesAttributeStaging
        PRIMARY KEY CLUSTERED (AttributeId)
);
GO