/*************************************
Purpose:
	To hold super package data exported
	from labkey generated packages

*************************************/

-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS TAC_src.SuperPkgs;


CREATE TABLE [TAC_src].[SuperPkgs](
    [SuperPkgId] [int] NOT NULL,
    [ParentSuperPkgId] [int] NULL,
    [PkgId] [int] NOT NULL,
    [SuperPkgPath] [varchar](900) NOT NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [SortOrder] [int] NULL,
    [Required] [bit] NOT NULL,
    CONSTRAINT PK_TAC_SuperPkgs
    PRIMARY KEY CLUSTERED (SuperPkgId ASC),
    ) ON [animal_data_grp]

-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.Projects TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.Projects TO z_labkey;
GO


