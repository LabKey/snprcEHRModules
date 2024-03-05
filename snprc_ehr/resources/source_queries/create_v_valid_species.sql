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
ALTER VIEW [labkey_etl].[v_valid_species]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/23/2015
-- Description:	Selects the ETL records for LabKey ehr_lookups.species dataset
-- Changes:
--
-- 2/1/2016 Added blood draw related columns. tjh
-- 11/14/2016  added modified, modifiedby, created, and createdby columns + code cleanup tjh
-- 2/19/2024 trimmed white space from common name and scientific name fields. SysAid Incident #16419
-- ==========================================================================================

SELECT
  vs.tid                           AS rowid,
  vs.species_code,
  ltrim(rtrim(vs.common_name))     AS common,
  ltrim(rtrim(vs.scientific_name)) AS scientific_name,
  vs.arc_species_code,
  avs.primate,
  avs.common_name                  AS arc_common_name,
  avs.scientific_name              AS arc_scientific_name,
  vs.blood_per_kg,
  vs.blood_draw_interval,
  vs.max_draw_pct,
  vs.object_id                     AS objectid,
  vs.entry_date_tm                 AS modified,
  dbo.f_map_username(vs.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  (SELECT MAX(v)
   FROM (VALUES (vs.timestamp), (avs.timestamp)) AS VALUE ( v )
  )                                AS timestamp
FROM dbo.valid_species AS vs
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vs.object_id
  INNER JOIN dbo.arc_valid_species_codes AS avs ON avs.arc_species_code = vs.arc_species_code

GO

GRANT SELECT ON labkey_etl.v_valid_species TO z_labkey;
GO

