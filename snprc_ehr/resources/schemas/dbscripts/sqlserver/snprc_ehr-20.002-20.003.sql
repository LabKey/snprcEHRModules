/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change databypes to match those in lookup tables.

srr 03.09.2020 version 20.003
Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';



CREATE TABLE [snprc_ehr].[NewAnimalData](
    [Id] [nvarchar](32) NOT NULL,
    [BirthDate] [datetime] NULL,
    [AcquisitionType] [int] NULL,
    [AcqDate] [datetime] NULL,
    [Gender] [nvarchar](10) NULL,
    [Sire] [nvarchar](32) NULL,
    [Dam] [nvarchar](32) NULL,
    [Species] [nvarchar](3) NULL,
    [Colony] [int] NULL,
    [AnimalAccount] [int] NULL,
    [OwnerInstitution] [int] NULL,
    [ResponsibleInstitution] [int] NULL,
    [Room] [int] NULL,
    [Cage] [int] NULL,
    [Diet] [int] NULL,
    [Pedigree] [int] NULL,
    [IACUC] [int] NULL,
    [Created] [datetime] NULL,
    [CreatedBy] [dbo].[USERID] NULL,
    [Modified] [datetime] NULL,
    [ModifiedBy] [dbo].[USERID] NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [objectid] [uniqueidentifier] NOT NULL,
        CONSTRAINT PK_snprc_NEWANIMALDATA   PRIMARY KEY (Id)
);