/*******************************************************
New table to load data from new animal wizard.
  Data will be ETLed back down to animal database

srr 01.28.2020

  May not use all columns.
  I defaulted to nvarchar(400) if unsure of datatype.
  May need to change datatypes to match those in lookup tables.

srr 03.09.2020 version 20.003
  Changed to ints for values that have a dropdown.
  No Real data, therefore dropping table and re-recreating.
srr 06.08.2020 version 20.007
  Added column for BirthCode.
    1   DOB accurate
    2   Month-Year accurate
    3   Year accurate
  No Real data, therefore dropping table and re-recreating.

 srr 06.24.2020
  Changed Diet, AnimalAccount and IACUC to strings
 srr 04012021 version 21.000
*******************************************************/

EXEC core.fn_dropifexists 'NewAnimalData','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.NewAnimalData
(
    Id                     nvarchar(32)     NOT NULL,
    BirthDate              datetime         NULL,
    BirthCode              int              NULL,
    AcquisitionType        int              NULL,
    AcqDate                datetime         NULL,
    SourceInstitutionLocation   nvarchar(10) NULL,
    Gender                 nvarchar(10)     NULL,
    Sire                   nvarchar(32)     NULL,
    Dam                    nvarchar(32)     NULL,
    Species                nvarchar(3)      NULL,
    Colony                 int              NULL,
    AnimalAccount          nvarchar(16)     NULL,
    OwnerInstitution       int              NULL,
    ResponsibleInstitution int              NULL,
    Room                   int              NULL,
    Cage                   int              NULL,
    Diet                   nvarchar(20)     NULL,
    Pedigree               int              NULL,
    IACUC                  nvarchar(200)    NULL,
    Created                datetime         NULL,
    CreatedBy              dbo.USERID       NULL,
    Modified               datetime         NULL,
    ModifiedBy             dbo.USERID       NULL,
    Container              dbo.ENTITYID     NOT NULL,
    objectid               uniqueidentifier NOT NULL,
    CONSTRAINT PK_snprc_NEWANIMALDATA PRIMARY KEY (Id)
);