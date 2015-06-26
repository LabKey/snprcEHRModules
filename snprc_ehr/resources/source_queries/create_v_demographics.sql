

ALTER view Labkey_etl.v_demographics AS (
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 12/2014
-- Description:	Selects the ETL records for LabKey demographics data
-- Changes:
--
--
-- ==========================================================================================

select m.object_id as objectid, 
	m.id AS id, 
	m.entry_date_tm AS date, 
	m.birth_date as birth, 
	m.death_date as death, 
	m.dam_id AS dam_id,
	m.sire_id AS sire_id,
	m.sex AS gender, 
	lower(avs.common_name) as species,
	m.entry_date_tm AS entry_date_tm,
	m.user_name AS user_name 
from master m 
INNER JOIN valid_species vs on m.species = vs.species_code
INNER JOIN arc_valid_species_codes avs on vs.arc_species_code = avs.arc_species_code
INNER JOIN current_data AS cd ON m.id = cd.id
INNER JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'
)

GO

grant SELECT on labkey_etl.V_DEMOGRAPHICS to z_labkey

GO