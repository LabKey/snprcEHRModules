ALTER VIEW [labkey_etl].[V_ANIMAL_OWNERSHIP] AS
/*
 * Copyright (c) 2016-2018 LabKey Corporation
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

CREATE VIEW [labkey_etl].[V_ANIMAL_OWNERSHIP] as
-- ====================================================================================================================
-- Object: v_animal_ownership
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- 11/3/2016  added modified, modifiedby, created, and createdby columns tjh
-- ==========================================================================================


SELECT
  a.id,
  a.assign_date                   AS date,
  a.owner_institution_id          AS owner_institution,
  a.institution_acquired_from_id  AS institution_acquired_from,
  a.end_date                      AS enddate,
  a.entry_date_tm                 AS modified,
  dbo.f_map_username(a.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  a.object_id                     AS objectid,

  a.timestamp

FROM dbo.animal_ownership a
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = a.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.ID

GO

GRANT SELECT ON labkey_etl.V_ANIMAL_OWNERSHIP TO z_labkey

GO