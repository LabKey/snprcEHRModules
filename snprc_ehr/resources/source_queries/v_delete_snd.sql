
CREATE VIEW [labkey_etl].[v_delete_snd] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/6/2023
-- Description: Selects the records to delete from snd staging tables
-- Changes:
--
--
-- ==========================================================================================
SELECT asp.object_id AS ObjectId,
	   asp.audit_date_tm
FROM audit.AUDIT_SUPER_PKGS AS asp
WHERE asp.audit_action = 'D' AND asp.object_id IS NOT NULL

UNION

SELECT ap.object_id AS ObjectId,
	   ap.audit_date_tm
FROM audit.AUDIT_PKGS AS ap
WHERE ap.audit_action = 'D' AND ap.object_id IS NOT NULL

UNION

SELECT apa.object_id AS ObjectId,
	   apa.audit_date_tm
FROM audit.AUDIT_PKG_ATTRIBS AS apa
WHERE apa.audit_action = 'D' AND apa.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.v_delete_snd to z_labkey
GRANT SELECT ON audit.AUDIT_SUPER_PKGS TO z_labkey
GRANT SELECT ON audit.AUDIT_PKGS TO z_labkey
GRANT SELECT ON audit.AUDIT_PKG_ATTRIBS TO z_labkey

GO