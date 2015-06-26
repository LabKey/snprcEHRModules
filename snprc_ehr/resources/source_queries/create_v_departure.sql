USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DEPARTURE]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DEPARTURE                                            */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DEPARTURE] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2015
-- Description:	Selects the ETL records for LabKey study.departure dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	m.id AS id, 
	ad.disp_date_tm AS date, 
	vdc.description AS description,
	ad.user_name AS user_name,
	ad.entry_date_tm AS entry_date_tm,
	ad.object_id AS objectid,
	ad.timestamp AS timestamp
FROM dbo.acq_disp AS ad
INNER JOIN master AS m ON m.id = ad.id
INNER JOIN dbo.valid_disp_codes AS vdc ON vdc.disp_code = ad.disp_code
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ad.id
GO

GRANT SELECT ON Labkey_etl.v_departure TO z_labkey 
GO

