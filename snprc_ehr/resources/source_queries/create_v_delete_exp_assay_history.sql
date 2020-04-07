

ALTER VIEW labkey_etl.v_delete_exp_assay_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/6/2020
-- Description:	Selects the deleted records for exposure ETL- assay_history data
-- Changes:
--
--
-- ==========================================================================================

SELECT
    ad.object_id,
    ad.audit_date_tm
FROM exposure.dbo.audit_assay_history AS ad
-- select primates only from the TxBiomed colony
         INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ad.id
WHERE ad.audit_action = 'D' AND ad.object_id IS NOT NULL

    GO

GRANT SELECT ON Labkey_etl.v_delete_exp_assay_history TO z_labkey
--GRANT SELECT ON exposure.dbo.audit_assay_history TO z_labkey

    GO

