USE animal
GO 
/*
	Error log for demographics export errors
*/
-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'LIS')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA LIS' );
END

DROP TABLE IF EXISTS LIS.HL7ExportErrorLog;

CREATE TABLE LIS.HL7ExportErrorLog
(
	[RowId] [NUMERIC](18, 0) IDENTITY(1,1) NOT NULL,
	[ObjectId] [VARCHAR](50) NOT NULL,
	[ProcessedDateTm] [DATETIME] NULL,
	[MessageControlId] [VARCHAR](50) NULL,
	[PatientId] [VARCHAR](20) NULL,
	[ErrorMsg] [VARCHAR](MAX) NULL,
	[UserName] [VARCHAR](128) NOT NULL,
	[EntryDateTm] [DATETIME] NOT NULL,
    CONSTRAINT PK_TAC_HL7ExportErrorLog
        PRIMARY KEY CLUSTERED (RowId ASC)
)

GO

-- Table permissions
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON LIS.HL7ExportErrorLog TO z_labkey;
GRANT VIEW DEFINITION ON LIS.HL7ExportErrorLog TO z_labkey;

GO