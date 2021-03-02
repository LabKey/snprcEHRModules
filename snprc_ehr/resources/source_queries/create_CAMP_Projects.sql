/**********************************************************
analogous to budgets
Added tid identity field for PK
***********************************************************/

-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS TAC_src.Projects;

CREATE TABLE [TAC_src].[Projects](
    [tid] INT IDENTITY NOT NULL,
    [ProjectId] [int] NOT NULL,
    [RevisionNum] [int] NOT NULL,
    [ReferenceId] [int] NOT NULL,
    [StartDate] [date] NOT NULL,
    [EndDate] [date] NULL,
    [Description] [nvarchar](4000) NOT NULL,
    [Active] [bit] NOT NULL,
    [ObjectId] [uniqueidentifier] NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    CONSTRAINT PK_TAC_Project PRIMARY KEY CLUSTERED (tid ASC),
    CONSTRAINT AK_TAC_Projects_ObjectId UNIQUE NONCLUSTERED (Objectid)
  )
    GO

-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.Projects TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.Projects TO z_labkey;
GO
