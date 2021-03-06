-- noinspection SqlResolveForFile

/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
-- 5/24/2016  Added rearing column. tjh
-- 9/6/2016   Removed join with arc_valid_species_codes
--            Animals that were never members of our colony do not have a current_data record, so
--            the join with this table was changed from inner to left. tjh
-- 11/3/2016  added modified, modifiedby, created, and createdby columns
-- 11/10/2020 Added logic to evaluate timestamps for new acq and disp entries. tjh
-- ==========================================================================================

select m.object_id as objectid,
	m.id AS id,
	m.entry_date_tm AS date,
	m.birth_date as birth,
	m.death_date as death,
	m.dam_id AS dam_id,
	m.sire_id AS sire_id,
	m.sex AS gender,
	m.species as species,
	CASE WHEN cd.at_sfbr = 'Y' THEN 'Alive' WHEN (cd.at_sfbr = 'N' AND m.death_date IS NULL) THEN 'Other' ELSE 'Dead' END AS status,
	r.rearing_code AS rearing_type,
	(SELECT MAX(v) FROM (VALUES  (r.timestamp), (m.timestamp), (cd.timestamp)) AS VALUE (v)) AS timestamp,
	m.entry_date_tm AS modified,
	dbo.f_map_username(m.user_name) AS modifiedby,
	tc.created AS created,
	tc.createdby AS createdby

from master m
    INNER JOIN valid_species vs on m.species = vs.species_code
    INNER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = m.object_id
    LEFT OUTER JOIN current_data AS cd ON m.id = cd.id
    LEFT OUTER JOIN dbo.rearing AS r ON m.id = r.id
WHERE vs.arc_species_code <> 'MD'
)

GO

grant SELECT on labkey_etl.V_DEMOGRAPHICS to z_labkey

GO
