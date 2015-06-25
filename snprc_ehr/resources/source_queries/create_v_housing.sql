USE [animal]
GO

/****** Object:  View [labkey_etl].[V_HOUSING]    Script Date: 12/31/2014 2:54:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_HOUSING                                              */
/*==============================================================*/


ALTER VIEW [labkey_etl].[V_HOUSING] AS
-- ====================================================================================================================
-- Object: v_housing
-- Author:	Terry Hawkins
-- Create date: 1/2015
-- ==========================================================================================

SELECT L.ID AS id, 
	L.MOVE_DATE_TM AS date,
	CAST(L.location AS VARCHAR(10)) AS room,
	L.OBJECT_ID AS objectid,
	L.entry_date_tm AS entry_date_tm,
	L.user_name AS user_name,
	L.TIMESTAMP
FROM location AS L
INNER JOIN master AS m ON m.id = L.id
INNER JOIN valid_species vs ON m.species = vs.species_code 
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
JOIN current_data AS cd ON m.id = cd.id
JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'
--WHERE L.move_date_tm > '1/1/2014 00:00'

GO


