USE animal
GO 

-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LIS')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA LIS' );
END

DROP TABLE IF EXISTS LIS.DemographicsHL7Staging;

CREATE TABLE LIS.DemographicsHL7Staging
(
    RowId INT IDENTITY,
    Id VARCHAR(6) NOT NULL,
    Gender CHAR(1) NULL,
    BirthDate DATETIME NULL,
    DeathDate DATETIME NULL,
    Breed VARCHAR(2) NULL,  -- arc_species_code
    Species VARCHAR(MAX) NULL, -- common name
    isAlive Varchar(1) NULL, -- Y/N/NULL
    Sire VARCHAR(6) NULL,
    Dam VARCHAR(6) NULL,
    Modified DATETIME NULL,
    ModifiedBy VARCHAR(MAX) NULL,
    Processed INT DEFAULT 0 NOT NULL, -- will be 0 when data is exported, and stored procedure will update it to 1 when processed
    ObjectId UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
    CONSTRAINT PK_TAC_DemographicsHL7Staging
        PRIMARY KEY CLUSTERED (RowId ASC)
)

GO

-- Table permissions
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON LIS.DemographicsHL7Staging TO z_labkey;
GRANT VIEW DEFINITION ON LIS.DemographicsHL7Staging TO z_labkey;

GO