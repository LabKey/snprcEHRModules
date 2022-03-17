CREATE VIEW labkey_etl.v_demographics_for_delete
AS  (
    -- ==========================================================================================
    -- Author:		Terry Hawkins
    -- Create date: 7/2/2021
    -- Description:	Selects the valid animal IDs for delete data sources
    -- Changes:
    -- ==========================================================================================

    SELECT
        m.id AS id
    FROM
        dbo.master m
    WHERE
        m.species <> 'MDA'
    UNION
    SELECT
        am.id AS id
    FROM
        audit.audit_master am
    WHERE
        am.species <> 'MDA'
        AND am.audit_action = 'D');

GO

GRANT
    SELECT
    ON labkey_etl.v_demographics_for_delete
    TO
    z_labkey;

GO
