/**********************************************************
ProjectItems
Not sure AK is needed, but added since objectId is not table PK
Added Alternate key AK_TAC_ProjectItems_ObjectId

Likely needs FK to Projects
***********************************************************/

-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS labkey_etl.ProjectItems;
DROP TABLE IF EXISTS TAC_src.ProjectItems;

CREATE TABLE [TAC_src].[ProjectItems](
    [ProjectItemId] [int] IDENTITY(1,1) NOT NULL,
    [ParentObjectId] [uniqueidentifier] NULL,
    [SuperPkgId] [int] NOT NULL,
    [Active] [bit] NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [Objectid] [uniqueidentifier] NOT NULL,
    CONSTRAINT PK_TAC_ProjectItems
    PRIMARY KEY CLUSTERED (ProjectItemId ASC),
    CONSTRAINT AK_TAC_ProjectItems_ObjectId
    UNIQUE NONCLUSTERED (Objectid)

    )
-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.ProjectItems TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.ProjectItems TO z_labkey;
GO