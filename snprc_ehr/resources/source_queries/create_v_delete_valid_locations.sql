

CREATE VIEW [labkey_etl].[V_DELETE_VALID_LOCATIONS] AS
-- ===========================================================================================================
-- Object: v_delete_valid_locations
-- Author:		Scott Rouse
-- Create date: 3/14/2018
--  Using room because LK table does not have objectID
-- ===========================================================================================================
SELECT
  avl.location as [room],
  avl.audit_date_tm

FROM audit.audit_valid_locations AS avl
WHERE avl.AUDIT_ACTION = 'D'

GO

GRANT SELECT ON Labkey_etl.V_DELETE_VALID_LOCATIONS TO z_labkey
GRANT SELECT ON audit.audit_valid_locations TO z_labkey
