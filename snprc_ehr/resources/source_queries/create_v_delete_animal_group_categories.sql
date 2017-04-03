ALTER VIEW [labkey_etl].[V_DELETE_ANIMAL_GROUP_CATEGORIES] as
-- ====================================================================================================================
-- Object: v_delete_animal_group_categoriess
-- Author:		Terry Hawkins
-- Create date: 2/20/2017
-- 
-- ==========================================================================================
SELECT 
	avc.object_id,
	avc.audit_date_tm

FROM audit.audit_animal_group_categories AS avc
WHERE avc.AUDIT_ACTION = 'D' AND avc.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_GROUP_CATEGORIES to z_labkey
GRANT SELECT ON audit.audit_animal_group_categories TO z_labkey

go