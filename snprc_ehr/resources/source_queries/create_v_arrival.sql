USE [animal]
GO

/****** Object:  View [labkey_etl].[V_ARRIVAL]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_ARRIVAL                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ARRIVAL] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2015
-- Description:	Selects the ETL records for LabKey study.arrival dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	m.id AS id, 
	ad.acq_date_tm AS date, 
	ad.acq_code AS acquisitionType,
	--m.dam_id AS dam,
	--m.sex AS gender,
	--LOWER(avs.common_name) AS species,
	--m.sire_id AS sire,
	--m.birth_date AS birth,
	CASE WHEN m.bd_status <> 0 THEN 'True' ELSE 'False' END AS estimated,
	m.entry_date_tm AS entry_date_tm,
	ad.user_name AS user_name,
	ad.object_id AS objectid
FROM dbo.acq_disp AS ad
INNER JOIN master AS m ON m.id = ad.id
INNER JOIN valid_species vs ON m.species = vs.species_code 
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
JOIN current_data AS cd ON m.id = cd.id
JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'

GO

GRANT SELECT ON Labkey_etl.v_arrival TO z_labkey 
GRANT SELECT ON Labkey_etl.v_arrival TO z_camp_base
GO

