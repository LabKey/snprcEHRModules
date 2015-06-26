USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DEATHS		                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DEATHS] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/2/2015
-- Description:	Selects the ETL records for LabKey study.deaths dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	m.id AS id, 
	m.death_date AS date, 
	m.dd_status AS date_type,
	vdc.description AS cause,
	m.object_id AS objectid,
	m.entry_date_tm AS entry_date_tm,
	m.user_name AS user_name,
	m.timestamp AS timestamp
FROM master m
INNER JOIN valid_disp_codes AS vdc ON m.death_code = vdc.disp_code
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = m.id

WHERE m.death_date IS NOT null

GO

GRANT SELECT ON Labkey_etl.v_deaths TO z_labkey 
GO

