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

ALTER VIEW [labkey_etl].[v_clinical_admissions] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/22/2015
-- Description:	Selects the clinical admissions for LabKey study.clinical_observations dataset`
-- Note:
--
-- Changes:
-- 9/25/2015	Removed animal id from ParticipantSequenceNum. tjh
-- 8/8/2016		added sdx, admit_complaint, resolution, and retarget vet to assignedvet column
-- 11/10/2016  added modified, modifiedby, created, and createdby columns tjh
-- 7/1/2021    removed ParticipantSequenceNum column. tjh
-- ==========================================================================================


SELECT
  c.id                             AS id,
  c.admit_date_tm                  AS date,
  c.release_date_tm                AS enddate,
  c.pdx                            AS problem,
  c.sdx                            AS sdx,
  c.admit_complaint                AS admitcomplaint,
  c.admit_id                       AS caseid,
  vac.description                  AS category,
  c.resolution                     AS resolution,
  c.charge_id                      AS project,
  v.tid                            AS assignedvet,
  c.object_id                      AS objectid,
  c.entry_date_tm                  AS modified,
  dbo.f_map_username(c.user_name)  AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  c.timestamp                      AS timestamp


FROM dbo.clinic AS c
  INNER JOIN dbo.valid_admit_codes AS vac ON vac.admit_code = c.admit_code
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id
  LEFT OUTER JOIN dbo.valid_vet AS v ON c.vet_name = v.vet_name
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = c.object_id


GO


GRANT SELECT ON [labkey_etl].[v_clinical_admissions] TO z_labkey

GO
