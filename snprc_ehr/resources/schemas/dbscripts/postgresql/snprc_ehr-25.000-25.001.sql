DROP TABLE IF EXISTS snprc_ehr.SndSuperPackageStaging;

CREATE TABLE snprc_ehr.SndSuperPackageStaging
(
    TopLevelPkgId INTEGER NOT NULL,
    SuperPkgId INTEGER NOT NULL,
    ParentSuperPkgId INTEGER NULL,
    PkgId INTEGER NOT NULL,
    TreePath VARCHAR(800) NOT NULL,
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
    ObjectId ENTITYID NOT NULL,

    CONSTRAINT PK_SndSuperPackageStaging PRIMARY KEY (TopLevelPkgId, SuperPkgId, TreePath)
);
