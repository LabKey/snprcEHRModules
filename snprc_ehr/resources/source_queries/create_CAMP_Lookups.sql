/**********************************************************

Will go to CAMP lookup_table
  02.24.2021
  srr
***********************************************************/

-- new schema
DROP TABLE IF EXISTS TAC_src.Lookups;


CREATE TABLE [TAC_src].[Lookups](
    [LookupSetId] [int] NOT NULL,
    [Value] [nvarchar](446) NOT NULL,
    [Displayable] [bit] NOT NULL,
    [SortOrder] [int] NULL,
    [Container] [uniqueidentifier] NOT NULL,
    [CreatedBy] [int] NULL,
    [Created] [datetime] NULL,
    [ModifiedBy] [int] NULL,
    [Modified] [datetime] NULL,
    [Lsid] [nvarchar](300) NULL,
    [LookupId] [int] IDENTITY(1,1) NOT NULL,
    [ObjectId] [uniqueidentifier] NOT NULL
    CONSTRAINT PK_TAC_Lookups
    PRIMARY KEY CLUSTERED (LookupId ASC)
    )


-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.Lookups TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.Lookups TO z_labkey;
GO