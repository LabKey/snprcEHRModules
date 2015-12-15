/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


ALTER view Labkey_etl.v_demographics AS (
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 12/2014
-- Description:	Selects the ETL records for LabKey demographics data
-- Changes:
-- 12/11/2015 changed species source from common_name to three character species code. tjh
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
	--lower(avs.common_name) as species,
	m.species as species,
	m.entry_date_tm AS entry_date_tm,
	CASE WHEN cd.at_sfbr = 'Y' THEN 'Alive' WHEN (cd.at_sfbr = 'N' AND m.death_date IS NULL) THEN 'Other' ELSE 'Dead' END AS status,
	m.user_name AS user_name, 
	m.timestamp
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