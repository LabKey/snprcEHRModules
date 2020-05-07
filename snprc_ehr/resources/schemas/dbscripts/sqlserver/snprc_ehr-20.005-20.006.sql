EXEC core.fn_dropifexists 'ValidDefaultIACUC','snprc_ehr', 'TABLE';


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
    ObjectId     UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ValidDefaultIACUC PRIMARY KEY (WorkingIacuc)
);