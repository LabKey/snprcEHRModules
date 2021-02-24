

-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS TAC_src.Pkgs;


CREATE TABLE [TAC_src].[PkgCategories](
    [CategoryId] [int] NOT NULL,
    [Description] [nvarchar](4000) NOT NULL,
    [Comment] [nvarchar](4000) NULL,
    [Active] [bit] NOT NULL,
    [SortOrder] [int] NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
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
