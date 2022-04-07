USE animal
GO 
/*
	Import log for results from Orchard Harvest
*/
-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LIS')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA LIS' );
END

DROP TABLE IF EXISTS LIS.HL7ImportLog;

CREATE TABLE LIS.HL7ImportLog
(
	[RowId] [NUMERIC](18, 0) IDENTITY(1,1) NOT NULL,
	[MessageId] [VARCHAR](50) NOT NULL,
	[ObservationDateTm] [DATETIME] NULL,
	[MessageControlId] [VARCHAR](50) NULL,
	[ImportStatus] [INT] NOT NULL,
	[ResultStatis] [VARCHAR](10) NULL,
	[PatientId] [VARCHAR](20) NULL,
	[Species] [VARCHAR](50) NULL,
	[HL7MessageText] [VARCHAR](MAX) NULL,
	[ImportText] [VARCHAR](MAX) NULL,
	[UserName] [VARCHAR](128) NOT NULL,
	[EntryDateTm] [DATETIME] NOT NULL,
	[TIMESTAMP] [TIMESTAMP] NULL,
    CONSTRAINT PK_TAC_HL7ImportLog
        PRIMARY KEY CLUSTERED (RowId ASC)
)

GO

-- Table permissions
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON LIS.HL7ImportLog TO z_labkey;
GRANT VIEW DEFINITION ON LIS.HL7ImportLog TO z_labkey;

GO