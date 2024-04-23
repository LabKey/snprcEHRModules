EXEC core.fn_dropifexists @objname = 'therapy_formulary', @objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'therapy_frequency', @objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'therapy_routes', @objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'therapy_units', @objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'therapy_resolutions', @objschema = 'snprc_ehr', @objtype = 'TABLE';

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
     ObjectId UNIQUEIDENTIFIER NOT NULL

     CONSTRAINT PK_therapy_formulary  PRIMARY KEY CLUSTERED (RowId)
)

ALTER TABLE snprc_ehr.therapy_formulary  WITH CHECK ADD  CONSTRAINT FK_therapy_formulary_container FOREIGN KEY(Container)
    REFERENCES core.Containers (EntityId)
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
     ObjectId UNIQUEIDENTIFIER NULL

     CONSTRAINT PK_therapy_routes  PRIMARY KEY CLUSTERED (RowId)
)
ALTER TABLE snprc_ehr.therapy_routes  WITH CHECK ADD  CONSTRAINT FK_therapy_routes FOREIGN KEY(Container)
    REFERENCES core.Containers (EntityId)
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
     ObjectId UNIQUEIDENTIFIER NULL

     CONSTRAINT PK_therapy_units  PRIMARY KEY CLUSTERED (RowId)
)
ALTER TABLE snprc_ehr.therapy_units  WITH CHECK ADD  CONSTRAINT FK_therapy_units FOREIGN KEY(Container)
    REFERENCES core.Containers (EntityId)
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
    ObjectId   UNIQUEIDENTIFIER NULL

    CONSTRAINT PK_therapy_resolutions PRIMARY KEY CLUSTERED (RowId)
)

ALTER TABLE snprc_ehr.therapy_resolutions  WITH CHECK ADD  CONSTRAINT FK_therapy_resolutions FOREIGN KEY(Container)
     REFERENCES core.Containers (EntityId)
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
     ObjectId UNIQUEIDENTIFIER NOT NULL

     CONSTRAINT PK_therapy_frequency  PRIMARY KEY CLUSTERED (RowId)
)
ALTER TABLE snprc_ehr.therapy_frequency  WITH CHECK ADD  CONSTRAINT FK_therapy_frequency FOREIGN KEY(Container)
    REFERENCES core.Containers (EntityId)
    GO




