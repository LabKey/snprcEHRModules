CREATE VIEW [labkey_etl].[V_DELETE_VALID_INSTITUTIONS] AS
-- ====================================================================================================================
-- Object: v_delete_valid_institutions
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- ==========================================================================================
SELECT
	avi.object_id,
	avi.audit_date_tm

FROM audit.audit_valid_institutions AS avi
WHERE avi.AUDIT_ACTION = 'D' AND avi.OBJECT_ID IS NOT NULL

GO
