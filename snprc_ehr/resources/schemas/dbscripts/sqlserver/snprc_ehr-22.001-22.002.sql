EXEC core.fn_dropifexists @objname = 'HL7_PathologyCasesStaging',@objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'HL7_PathologyDiagnosesStaging',@objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'HL7_DeletePathologyCasesStaging',@objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'HL7_DeletePathologyDiagnosesStaging',@objschema = 'snprc_ehr', @objtype = 'TABLE';
EXEC core.fn_dropifexists @objname = 'HL7_Demographics', @objschema = 'snprc_ehr', @objtype = 'TABLE';

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
     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
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
     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TABLE snprc_ehr.HL7_DeletePathologyCasesStaging (
     AccessionNumber NVARCHAR(10) NOT NULL,
     ObjectId UNIQUEIDENTIFIER NOT NULL,
     timestamp ROWVERSION

     CONSTRAINT PK_HL7_DeletePathologyCasesStaging PRIMARY KEY CLUSTERED
     (
     AccessionNumber ASC,
	 ObjectId ASC
     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TABLE snprc_ehr.HL7_DeletePathologyDiagnosesStaging (
     AccessionNumber NVARCHAR(10) NOT NULL,
     ObjectId uniqueidentifier NOT NULL,
     timestamp ROWVERSION

     CONSTRAINT PK_HL7_DeletePathologyDiagnosesStaging PRIMARY KEY CLUSTERED
     (
     AccessionNumber ASC,
	 ObjectId ASC
     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
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
         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
