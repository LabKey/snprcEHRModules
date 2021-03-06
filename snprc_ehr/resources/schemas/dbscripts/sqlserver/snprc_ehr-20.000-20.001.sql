/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change databypes to match those in lookup tables.

*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.NewAnimalData
(
    Id NVARCHAR(32) NOT NULL,
    BirthDate DATETIME NULL,
    AcquisitionType INT NULL,
    AcqDate DATETIME NULL,  -- Will use for all start dates in this dataset
    Gender NVARCHAR(10) NULL,         --gender nvarchar(4000)
    Sire NVARCHAR(32) NULL,
    Dam NVARCHAR(32) NULL,
    Species NVARCHAR(3) NULL, -- species, nvarchar(4000)
    Colony NVARCHAR(400) NULL,
    AnimalAccount NVARCHAR(400) NULL,
    OwnerInstitution INT NULL,       -- lookup snprc_ehr.validInstitutions
    ResponsibleInstitution INT NULL,       -- likely same as owner
    Location NVARCHAR(400) NULL,
    Diet NVARCHAR(400) NULL,
    Pedigree NVARCHAR(400) NULL,
    IACUC NVARCHAR(400) NULL,
    Created DATETIME NULL,
    CreatedBy dbo.USERID NULL,
    Modified DATETIME NULL,
    ModifiedBy dbo.USERID NULL,
    DiCreated DATETIME NULL,
    DiModified DATETIME NULL,
    DiCreatedBy dbo.USERID NULL,
    DiModifiedBy dbo.USERID NULL,
    Container ENTITYID NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_snprc_NEWANIMALDATA   PRIMARY KEY (Id)
);
--[DeliveryType]  [nvarchar](400) NULL,
--[BirthNature]   [nvarchar](400) NULL,
--[AcquireType]   [nvarchar](400) NULL,


/*
Species,
Acq_code,
id_type,
institution_id,
colony,
delivery_type,
birth_nature,
acquire_type,
animalAccounts,
location,
IACUC fields,
pedigree,
diet
 */



go
