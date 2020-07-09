/*******************************************************************
Creates TAC schema if needed, then table to hold new animal data
  entered in TAC


06.22.2020 srr

Changed the schema back to labkey_etl for simplicity.
  May revert back to TAC schema at a later date if there
  are more tables and better organization is needed.
  Left PK as PK_TAC_NEWANIMALDATA
07.06.2020 srr
*******************************************************************/

/*
-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'TAC')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA TAC' );
END
*/

-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS labkey_etl.NewAnimalData

CREATE TABLE labkey_etl.NewAnimalData
(
    Id VARCHAR(6) NOT NULL,
    BirthDate DATETIME NULL,
    Bd_Status INT NULL,
    AcquisitionType INT NULL,
    AcquisitionDate DATETIME NULL, -- Start date for Data Tables
    Gender CHAR(1) NULL,
    Sire VARCHAR(6) NULL,
    Dam VARCHAR(6) NULL,
    Species VARCHAR(3) NULL,
    ColonyText VARCHAR(30),
    PedigreeText VARCHAR(20) NULL,
    PedigreeInt INT NULL,
    AnimalAccount VARCHAR(15) NULL,
    OwnerInstitution INT NULL,
    ResponsibleInstitution INT NULL,
    Room VARCHAR(10) NULL, -- Bay
    Cage INT NULL,
    DietInt INT NULL,
    DietText VARCHAR(20) NULL,
    IACUC VARCHAR(7) NULL,
    Created DATETIME NULL,
    CreatedBy Int NULL,
    CreatedByEmail    VARCHAR(128) NULL,
    Modified DATETIME NULL,
    ModifiedBy Int NULL,
    ModifiedByEmail varchar(128) NULL,
    Container UNIQUEIDENTIFIER NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_TAC_NEWANIMALDATA
        PRIMARY KEY CLUSTERED (Id ASC)
)