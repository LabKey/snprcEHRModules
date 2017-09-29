CREATE VIEW [labkey_etl].[v_delete_snd_ProjectItems] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/28/2017
-- Description: Selects the records to delete from snd.Projects dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT abi.object_id,
	abi.audit_date_tm

FROM AUDIT.audit_budget_items AS abi

WHERE abi.audit_action = 'D' AND abi.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.v_delete_snd_ProjectItems to z_labkey
GRANT SELECT ON audit.AUDIT_BUDGET_ITEMS TO z_labkey

GO