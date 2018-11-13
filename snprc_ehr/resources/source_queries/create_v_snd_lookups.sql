
ALTER VIEW [labkey_etl].[v_snd_lookups] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 01/29/2018
-- Description:	Used as source for the Lookup table dataset ETL
-- Note:
--
-- Changes:
--02/16/2018 Changed IS_HIDDEN to displayable
--
-- ==========================================================================================
SELECT lt.LOOKUP_ID as [LookupId],
  lt.LOOKUP_KEY as [SetName],
  lt.VALUE,
  CASE WHEN lt.IS_HIDDEN = 'N' THEN 1 ELSE 0 END AS Displayable,
  lt.ORDER_NUM,
  lt.DEFAULT_FLAG,
  lt.OBJECT_ID AS [objectid],
  lt.ENTRY_DATE_TM AS [modified],
  dbo.f_map_username(lt.USER_NAME) AS [modifiedby],
  tc.created AS [created],
  tc.createdby AS [createdby],
  lt.TIMESTAMP

FROM [animal].[dbo].[LOOKUP_TABLE] lt
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = lt.object_id

go

GRANT SELECT ON [labkey_etl].[v_snd_lookups] TO z_labkey
GO

