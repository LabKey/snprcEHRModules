CREATE VIEW [labkey_etl].[v_delete_snd_lookups] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 01/30/2018
-- Description:	Used as source for the deleting lookups dataset ETL
-- Note: Sourced from v_delete_valid_institutions
--
-- Changes:
--
--
-- ==========================================================================================
SELECT al.OBJECT_ID,
  al.AUDIT_DATE_TM
FROM audit.AUDIT_LOOKUP_TABLE al
WHERE al.AUDIT_ACTION = 'D'
      AND al.OBJECT_ID IS NOT NULL



GO

--

GRANT SELECT ON labkey_etl.V_delete_snd_lookups TO z_labkey;
GRANT SELECT ON audit.AUDIT_LOOKUP_TABLE TO z_labkey;
go
