Create VIEW [labkey_etl].[v_delete_behavior_notification] as
-- ====================================================================================================================
-- Object: v_delete_b_notification
-- Author:		Scott Rouse
-- Create date: 04/10/2020
-- NOTE:  animal view is b_notification, not behavior_notification
--04.15.2020 updated name
---- ==========================================================================================
SELECT abn.object_id, abn.audit_date_tm
FROM audit.audit_b_notification abn
WHERE abn.audit_action = 'D' AND abn.object_id IS NOT NULL
    go

GRANT SELECT on labkey_etl.v_delete_b_notification to z_labkey
GRANT SELECT ON audit.audit_b_notification TO z_labkey

