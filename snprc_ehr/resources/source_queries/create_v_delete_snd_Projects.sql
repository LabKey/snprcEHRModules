CREATE VIEW [labkey_etl].[v_delete_snd_Projects] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/28/2017
-- Description: Selects the records to delete from snd.Projects dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT ab.object_id,
	ab.audit_date_tm
FROM AUDIT.audit_budgets AS ab

WHERE ab.audit_action = 'D' AND ab.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.v_delete_snd_Projects to z_labkey
GRANT SELECT ON audit.AUDIT_BUDGETS TO z_labkey

GO