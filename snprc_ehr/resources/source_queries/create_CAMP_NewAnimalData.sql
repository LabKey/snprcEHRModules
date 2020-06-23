/*******************************************************************
Creates TAC schema if needed, then table to hold new animal data
  entered in TAC


06.22.2020 srr
*******************************************************************/

-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'TAC')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA TAC' );
END



CREATE TABLE TAC.NewAnimalData
(
    Id VARCHAR(6) NOT NULL,
    BirthDate DATETIME NULL,
    BirthDateType INT NULL,
    AcquisitionType INT NULL,
    AcqDate DATETIME NULL, -- Start date for Data Tables
    Gender CHAR(1) NULL,
    Sire VARCHAR(6) NULL,
    Dam VARCHAR(6) NULL,
    Species VARCHAR(3) NULL,
    Colony VARCHAR(30) NULL,
    Pedigree VARCHAR(20) NULL,
    AnimalAccount VARCHAR(15) NULL,
    OwnerInstitution INT NULL,
    ResponsibleInstitution INT NULL,
    Area VARCHAR(10) NULL, --building
    Room VARCHAR(10) NULL, -- Bay
    Cage INT NULL,
    Diet VARCHAR(20) NULL,
    IACUC VARCHAR(7) NULL,
    Created DATETIME NULL,
    CreatedBy VARCHAR(128) NULL,
    Modified DATETIME NULL,
    ModifiedBy VARCHAR(128) NULL,
    Container UNIQUEIDENTIFIER NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_TAC_NEWANIMALDATA
        PRIMARY KEY CLUSTERED (Id ASC)
)