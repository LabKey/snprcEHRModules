/**********************************************************

I think this will go to CAMP pkgAttrib lookups
  ori date 02.24.2021
  srr
  Added SyncDateTime column with a default of getdate.
  Will change ETL dump entire table.
***********************************************************/
-- new schema
DROP TABLE IF EXISTS TAC_src.LookupSets;


CREATE TABLE [TAC_src].[LookupSets](
    [LookupSetId] [int] IDENTITY(1,1) NOT NULL,
    [SetName] [nvarchar](128) NOT NULL,
    [Label] [nvarchar](128) NULL,
    [Description] [nvarchar](900) NULL,
    [Container] [uniqueidentifier] NOT NULL,
    CreatedBy Int NULL,
    CreatedByEmail    VARCHAR(128) NULL,
    CreatedUserName VARCHAR(128) NULL,
    Modified DATETIME NULL,
    ModifiedBy Int NULL,
    ModifiedByEmail varchar(128) NULL,
    [Lsid] [nvarchar](300) NULL,
    [ObjectId] [uniqueidentifier] NOT NULL,
    ETLDownDate [DATETIME] DEFAULT GETDATE(),
    CONSTRAINT PK_TAC_LookupSetId
    PRIMARY KEY CLUSTERED (LookupSetId ASC)
    )


-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.LookupSets TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.LookupSets TO z_labkey;
GO