CREATE VIEW [labkey_etl].[v_delete_snd_PkgCategoryJunction] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/28/2017
-- Description:	Selects the records to delete from snd.PkgCategoryJunction dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT ap.object_id,
	ap.audit_date_tm
FROM AUDIT.AUDIT_PKG_CATEGORY AS ap
WHERE ap.audit_action = 'D' AND ap.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.v_delete_snd_PkgCategoryJunction to z_labkey
GRANT SELECT ON audit.AUDIT_PKG_CATEGORY TO z_labkey

GO