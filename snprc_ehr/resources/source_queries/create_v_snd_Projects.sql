/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
ALTER VIEW [labkey_etl].[v_snd_Projects] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 09/27/2017
-- Description:	selects the package_category data for the SND integration to snprc_ehr
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT
  b.budget_id AS ProjectId,
  b.revision_num AS RevisionNum,
  b.charge_id AS referenceId,
  b.start_date_tm AS StartDate,
  b.end_date_tm AS EndDate,
  b.BUDGET_TYPE AS ProjectType,
  CASE WHEN b.VS_NUM = 0 THEN NULL ELSE b.VS_NUM END AS VsNumber,
  b.description as Description,
  b.object_id                     AS objectid,
  b.entry_date_tm                 AS modified,
  dbo.f_map_username(b.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,
  b.timestamp                     AS timestamp,
  CASE WHEN COALESCE(b.end_date_tm, GETDATE()) < GETDATE() THEN 'false' ELSE 'true' END AS Active
          
FROM dbo.budgets AS b
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = b.object_id
  

GO
GRANT SELECT ON [labkey_etl].[v_snd_Projects] TO z_labkey

GO

