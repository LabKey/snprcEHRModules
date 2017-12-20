/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[V_HOUSING] AS
-- ====================================================================================================================
-- Object: v_housing
-- Author:	Terry Hawkins
-- Create date: 1/2015
-- Changes:
-- 11/11/2016  added modified, modifiedby, created, and createdby columns. tjh
-- 12/20/2017  query now sources function that combines locations and cage positions. tjh
-- ==========================================================================================
SELECT f.id,
  f.startDate AS date,
  COALESCE(LAG(f.startDate) OVER (PARTITION BY f.id ORDER BY f.startDate desc), cd.disp_date_tm_max) AS endDate,
  CAST(f.room AS VARCHAR(10)) AS room,
  f.cage,
  f.group_housing_flag,
  f.objectId AS objectid,
  f.entry_date_tm                               AS modified,
  dbo.f_map_username(f.user_name)               AS modifiedby,
  tc.created                                    AS created,
  tc.createdby                                  AS createdby,
  CAST(f.timestamp AS TIMESTAMP) AS timestamp

FROM labkey_etl.f_get_location_with_cage_position() AS f
  INNER JOIN dbo.current_data AS cd ON cd.id = f.id
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = f.id
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = f.base_objectId


GO

grant SELECT on labkey_etl.V_HOUSING to z_labkey
