
/*********  Create animal schema LabkeyETL if it doesn not exist ******/
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'TAC_src')
EXEC('CREATE SCHEMA [TAC_src] AUTHORIZATION [DBO]');




-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS labkey_etl.Pkgs;
-- new schema
DROP TABLE IF EXISTS TAC_src.Pkgs;


CREATE TABLE [TAC_src].[Pkgs](
    [PkgId] [int] NOT NULL,
    [Description] [nvarchar](4000) NOT NULL,
    [Active] [bit] NULL,
    [Repeatable] [bit] NULL,
    [QcState] [int] NULL,
    [ObjectId] [uniqueidentifier] NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [Narrative] [nvarchar](max) NULL
    CONSTRAINT PK_TAC_PKgs
    PRIMARY KEY CLUSTERED (PkgId ASC)
    )
    -- Not sure whys SSMS generated creat has TEXTIMAGE
    --ON [animal_data_grp] TEXTIMAGE_ON [animal_data_grp]
    GO
-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.Pkgs TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.Pkgs TO z_labkey;
GO

