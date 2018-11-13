
Alter VIEW [labkey_etl].[v_snd_lookupSets] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/16/2018
-- Description:	Used as source for the Lookup table dataset ETL
-- Note:
--
-- Changes:
--
--
-- ==========================================================================================
SELECT 
  pkl.LOOKUP_KEY as [SetName],
  pkl.OBJECT_ID AS [objectid],
  pkl.ENTRY_DATE_TM AS [modified],
  dbo.f_map_username(pkl.USER_NAME) AS [modifiedby],
  tc.created AS [created],
  tc.createdby AS [createdby],
  pkl.TIMESTAMP
FROM dbo.PKG_ATTRIB_LOOKUPS pkl
  
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
    ON tc.object_id = pkl.OBJECT_ID

go

GRANT SELECT ON [labkey_etl].[v_snd_lookupSets] TO z_labkey
GO

