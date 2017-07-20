CREATE VIEW [labkey_etl].[V_DELETE_LABWORK_TYPES] AS
  -- ==========================================================================================
  -- Object: v_delete_labwork_types
  -- Author:		Terry Hawkins
  -- Create date: 6/28/2016
  --
  -- ==========================================================================================
  SELECT
    lt.object_id,
    lt.audit_date_tm

  FROM audit.AUDIT_CLINICAL_PATH_LABWORK_TYPES AS lt
  WHERE lt.AUDIT_ACTION = 'D' AND lt.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON labkey_etl.V_DELETE_LABWORK_TYPES TO z_labkey
GRANT SELECT ON AUDIT.AUDIT_CLINICAL_PATH_LABWORK_TYPES TO z_labkey
GO