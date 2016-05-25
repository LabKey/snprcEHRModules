CREATE VIEW [labkey_etl].[V_DELETE_ANIMAL_OWNERSHIP] as
-- ====================================================================================================================
-- Object: v_delete_animal_ownership
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- ==========================================================================================
SELECT 
	aa.object_id,
	aa.audit_date_tm

FROM audit.audit_animal_ownership AS aa
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aa.id
WHERE aa.AUDIT_ACTION = 'D' AND aa.OBJECT_ID IS NOT NULL

go

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_OWNERSHIP to z_labkey
GRANT SELECT ON audit.audit_animal_ownership TO z_labkey


go