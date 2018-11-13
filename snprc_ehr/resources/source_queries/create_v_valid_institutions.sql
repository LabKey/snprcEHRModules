/*
 * Copyright (c) 2016 LabKey Corporation
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
ALTER VIEW [labkey_etl].[V_VALID_INSTITUTIONS] AS
-- ====================================================================================================================
-- Object: v_valid_institutions
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
-- Changes:
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
-- ==========================================================================================

SELECT
  vi.institution_id,
  vi.institution_name,
  vi.short_name,
  vi.city,
  vi.state,
  vi.affiliate,
  vi.web                           AS web_site,
  vi.object_id                     AS objectid,
  vi.entry_date_tm                 AS modified,
  dbo.f_map_username(vi.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  vi.timestamp
FROM dbo.valid_institutions AS vi
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vi.object_id

GO

GRANT SELECT ON labkey_etl.V_VALID_INSTITUTIONS TO z_labkey

GO