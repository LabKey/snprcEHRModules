USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DEPARTURE]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_ARRIVAL                                         */
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
	ad.user_name AS modifiedby,
	ad.object_id AS objectid
FROM dbo.acq_disp AS ad
INNER JOIN master AS m ON m.id = ad.id
INNER JOIN dbo.valid_disp_codes AS vdc ON vdc.disp_code = ad.disp_code
INNER JOIN valid_species vs ON m.species = vs.species_code 
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
JOIN current_data AS cd ON m.id = cd.id
JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'

GO

GRANT SELECT ON Labkey_etl.v_departure TO z_labkey 
GO

