SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION labkey_etl.f_get_location_with_cage_position ()
-- =============================================
-- Author:		Terry Hawkins
-- Create date: 12/20/2017
-- Description:	Combines location and cage position data
-- =============================================

RETURNS 
@moveTable TABLE (row INT IDENTITY(1,1) , 
	id VARCHAR(6), 
	startDate DATETIME, 
	endDate DATETIME, 
	room NUMERIC (7,2), 
	cage NUMERIC(7,2), 
	group_housing_flag VARCHAR (1),
	base_objectId uniqueidentifier,
	objectId VARCHAR(46), 
	entry_date_tm datetime,
	user_name VARCHAR(128),
	timestamp VARBINARY(8))


AS
BEGIN
	INSERT INTO @moveTable
        ( id ,
          startDate ,
          endDate ,
          room ,
          cage ,
          group_housing_flag,
		  objectId,
		  base_objectId,
		  entry_date_tm,
          user_name,
		  timestamp
        )

SELECT l.id, 
	(SELECT MIN(v) FROM (VALUES (cp.move_date_tm), (l.move_date_tm)) AS VALUE ( v )) AS startDate,
	--CASE WHEN cp.move_date_tm < l.move_date_tm THEN cp.move_date_tm ELSE l.move_date_tm END AS startDate,
	NULL AS endDate,
	l.location AS room, 
	cp.cage_position as cage,
	vl.group_housing_flag,
	CASE WHEN cp.cage_position IS NULL THEN CAST(l.object_id AS VARCHAR(45)) ELSE CAST(l.object_id AS VARCHAR(36))+ '/' + CAST(cp.cage_position AS VARCHAR(9)) END  AS objectId,
	l.object_id AS base_objectId,
	l.entry_date_tm   AS entry_date_tm,
	l.user_name     AS user_name,
	(SELECT MAX(v) FROM (VALUES (l.timestamp), (cp.timestamp)) AS VALUE ( v )) AS timestamp
	--CASE WHEN l.timestamp < cp.timestamp THEN cp.timestamp ELSE l.timestamp END AS timestamp

FROM dbo.location AS l
LEFT OUTER JOIN dbo.valid_locations AS vl ON vl.location = l.location
  -- select primates only from the TxBiomed colony

LEFT OUTER JOIN dbo.cage_position AS cp ON l.id = cp.id 
	AND CAST(cp.move_date_tm AS DATE) >=

		 (SELECT CAST(MIN(l2.move_date_tm) AS DATE) FROM dbo.location AS l2
		  WHERE cp.id = l.id 
			AND CAST(cp.move_date_tm AS DATE) >= CAST(l.move_date_tm AS DATE))
	
	AND cp.move_date_tm < CAST(COALESCE(l.exit_date_tm, GETDATE())  AS DATE)
	AND vl.group_housing_flag = 'N'
	
	RETURN 
END
GO

GRANT SELECT ON labkey_etl.f_get_location_with_cage_position TO z_labkey