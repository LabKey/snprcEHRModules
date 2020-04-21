CREATE VIEW [labkey_etl].[v_delete_b_c_notification] as
-- ====================================================================================================================
-- Object: v_delete_b_notification_comment
-- Author:		Scott Rouse
-- Create date: 04/10/2020
-- NOTE:  animal table is b_c_notification, not behavior_notification_comment
--
-- ==========================================================================================
SELECT bcn.object_id, bcn.audit_date_tm
FROM audit.audit_b_c_notification bcn
WHERE bcn.audit_action = 'D' AND bcn.object_id IS NOT NULL;
go

GRANT SELECT on labkey_etl.v_delete_b_c_notification to z_labkey;
GRANT SELECT ON audit.audit_b_c_notification TO z_labkey;