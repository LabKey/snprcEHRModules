alter VIEW [labkey_etl].[v_delete_snd_lookupSets] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/16/2018
-- Description:	Used as source for the deleting lookupSets dataset ETL
-- Note: Sourced from v_delete_lookup_table
--
-- Changes:
--
--
-- ==========================================================================================
SELECT pkl.OBJECT_ID,
  pkl.AUDIT_DATE_TM
FROM audit.AUDIT_PKG_ATTRIB_LOOKUPS pkl
WHERE pkl.AUDIT_ACTION = 'D'
      AND pkl.OBJECT_ID IS NOT NULL

GO

--

GRANT SELECT ON labkey_etl.v_delete_snd_lookupSets TO z_labkey;
GRANT SELECT ON audit.AUDIT_PKG_ATTRIB_LOOKUPS TO z_labkey;
go
