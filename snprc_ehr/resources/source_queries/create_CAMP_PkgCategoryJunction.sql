/**********************************************************

TBD
  02.24.2021
  srr
  Changed user data from INT to nvarchar(128) and appended "Text" to column name
  08.23.2021 srr

***********************************************************/
-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS TAC_src.PkgCategoryJunction;



CREATE TABLE [TAC_src].[PkgCategoryJunction](
    [tid] INT IDENTITY NOT NULL,
    [PkgId] [int] NOT NULL,
    [CategoryId] [int] NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedByText] [nvarchar](128) NULL,
    [Created] [datetime] NULL,
    [ModifiedByText] [nvarchar](128) NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [Objectid] [uniqueidentifier] NOT NULL
    CONSTRAINT PK_TAC_PkgCategoryJunction PRIMARY KEY CLUSTERED (tid ASC),
    CONSTRAINT AK_TAC_PkgCategoryJunction_ObjectId UNIQUE NONCLUSTERED (Objectid)

    )
    GO

-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.PkgCategoryJunction TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.PkgCategoryJunction TO z_labkey;
GO
