
ALTER VIEW [labkey_etl].[v_valid_locations]
AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 03/14/2018
-- Description:	Select for valid_locations.  Will replace rooms.tsv
-- Changes:
-- removed objectId not LK table
-- Added Left trim to description to cap at 100 char
-- 03.21.2018
-- Added close_date as dateDisabled.
--	Because SNPRC locations are date bound, has the potential for multiple rows for a single location.
--    None currently exists.  Not addressing at this time. srr

--
-- Note:  Had to add alt Key to XML.  Do not know why. srr

-- ==========================================================================================

SELECT cast(vl.location as varchar(100) )AS room,
  LEFT(vl.description,100) AS [building],
  CAST(vl.location AS INT) AS [area],
  vl.max_num_cages AS [maxCages],
  vl.location * 100 AS [sort_order],
  vl.close_date AS [dateDisabled],
  -- vl.object_id AS [objectid],
  vl.entry_date_tm AS [modified],
  dbo.f_map_username(vl.user_name) AS [modifiedby],
       tc.created                       AS created,
       tc.createdby                     AS createdby,
  vl.timestamp

FROM animal.dbo.valid_locations vl
  INNER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vl.object_id;

go

GRANT SELECT ON labkey_etl.v_valid_locations TO z_labkey;
GO
