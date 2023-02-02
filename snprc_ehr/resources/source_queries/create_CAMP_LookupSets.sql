/**********************************************************

I think this will go to CAMP pkgAttrib lookups
  02.24.2021
  srr
***********************************************************/
/******************************
WORKING NOTE:
Note as of 08.19.2021
Label, Description and Lsid are all null
on vogon
srr
  Changed user data from INT to nvarchar(128) and appended "Text" to column name
  08.23.2021 srr

******************************/

/*  DEV Note:  Table exists on vogon */

-- new schema
DROP TABLE IF EXISTS TAC_src.LookupSets;

CREATE TABLE [TAC_src].[LookupSets](
    [LookupSetId] [int] IDENTITY(1,1) NOT NULL,
    [SetName] [nvarchar](128) NOT NULL,
    [Label] [nvarchar](128) NULL,
    [Description] [nvarchar](900) NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedByText] [nvarchar](128) NULL,
    [Created] [datetime] NULL,
    [ModifiedByText] [nvarchar](128) NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [ObjectId] [uniqueidentifier] NOT NULL
    CONSTRAINT PK_TAC_LookupSetId
    PRIMARY KEY CLUSTERED (LookupSetId ASC)
    )

-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.LookupSets TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.LookupSets TO z_labkey;
GO