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