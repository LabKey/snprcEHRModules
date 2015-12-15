
-- Alters existing ehr_lookups.species table to include additional SNPRC species code columns columns needed
-- for ETLs (objectid)

CREATE PROCEDURE snprc_ehr.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT column_name
            FROM information_schema.columns
            WHERE table_name='species' and table_schema='ehr_lookups' and column_name='objectid')
        BEGIN
        -- Run variants of scripts from trunk

						ALTER TABLE ehr_lookups.species ADD species_code nvarchar(3);
						ALTER TABLE ehr_lookups.species ADD arc_species_code nvarchar(3);
						--ALTER TABLE ehr_lookups.species ADD arc_common_name nvarchar(255);
						--ALTER TABLE ehr_lookups.species ADD arc_scientific_name nvarchar(255);
						ALTER TABLE ehr_lookups.species ADD objectid nvarchar(4000);
						ALTER TABLE ehr_lookups.species ADD tid int;
        END
    END;

GO

EXEC snprc_ehr.handleUpgrade
GO

DROP PROCEDURE snprc_ehr.handleUpgrade
GO

