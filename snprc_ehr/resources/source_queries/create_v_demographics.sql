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
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 12/2014
-- Description:	Selects the ETL records for LabKey demographics data
-- Changes:
--
--
-- ==========================================================================================


CREATE view Labkey_etl.v_demographics AS (
select m.object_id as objectid, 
	m.id AS id, 
	m.entry_date_tm AS date, 
	m.birth_date as birth, 
	m.death_date as death, 
	m.dam_id AS dam_id,
	m.sire_id AS sire_id,
	m.sex AS gender, 
	lower(avs.common_name) as species 
from master m 
inner join valid_species vs on m.species = vs.species_code 
inner join arc_valid_species_codes avs on vs.arc_species_code = avs.arc_species_code
JOIN current_data AS cd ON m.id = cd.id
JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'
)

go

GRANT SELECT ON Labkey_etl.v_demographics TO z_camp_base
GO
