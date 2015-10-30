

CREATE PROCEDURE snprc_ehr.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT column_name
            FROM information_schema.columns
            WHERE table_name='package' and table_schema='snprc_ehr' and column_name='objectid')
        BEGIN
        -- Run variants of scripts from trunk

        ALTER TABLE snprc_ehr.package ADD objectid nvarchar(4000);
        ALTER TABLE snprc_ehr.package_category ADD objectid nvarchar(4000);
        ALTER TABLE snprc_ehr.package_category_junction ADD objectid nvarchar(4000);
        END
    END;

GO

EXEC snprc_ehr.handleUpgrade
GO

DROP PROCEDURE snprc_ehr.handleUpgrade
GO