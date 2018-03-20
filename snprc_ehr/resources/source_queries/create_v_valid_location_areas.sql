
CREATE VIEW [labkey_etl].[v_valid_location_areas]
AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 03/16/2018
-- Description:	Select for valid_locationAreas.  Will replace rooms.tsv
-- Changes:
-- removed objectId not LK table
-- Added Left trim to description to cap at 100 char
--
-- Does not have object_id or created, modified columna.
-- Removed them 03.19.2018 stt
-- ==========================================================================================

SELECT DISTINCT cast(vl.location as int) AS area
FROM dbo.valid_locations vl

go

GRANT SELECT ON labkey_etl.v_valid_location_areas TO z_labkey;