/********************************************************************************

  Changed user data from INT to nvarchar(128) and appended "Text" to column name
  08.23.2021 srr

*********************************************************************************/


-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS TAC_src.PkgCategories;


CREATE TABLE [TAC_src].[PkgCategories](
    [CategoryId] [int] NOT NULL,
    [Description] [nvarchar](4000) NOT NULL,
    [Comment] [nvarchar](4000) NULL,
    [Active] [bit] NOT NULL,
    [SortOrder] [int] NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedByText] [nvarchar](128) NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [ModifiedText] [nvarchar](128) NULL,
    [Lsid] [nvarchar](300) NULL,
    [Objectid] [uniqueidentifier] NOT NULL
    CONSTRAINT PK_TAC_PkgCategories
    PRIMARY KEY CLUSTERED (CategoryId ASC)
    )
-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.PkgCategories TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.PkgCategories TO z_labkey;
GO
    GO
