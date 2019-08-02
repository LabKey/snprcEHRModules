
EXEC core.fn_dropifexists 'ValidVaccines','snprc_ehr', 'TABLE';

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
    objectid     uniqueidentifier NOT NULL
        CONSTRAINT PK_ValidVaccine PRIMARY KEY CLUSTERED (Vaccine ASC)
)
