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
USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: v_animal_group_members                                 */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_GROUP_MEMBERS] AS
-- ====================================================================================================================
-- Object: v_animal_group_members
-- Author: Terry Hawkins
-- Create date: 8/28/2015
--
-- 11/12/15 - Added 'Breeding grp:' to groupName to match v_animal_groups. tjh
-- 3/1/2016 - Added valid_pedigrees. tjh
-- 3/3/2016 - Added account_group. tjh
-- 11/3/2016  added modified, modifiedby, created, and createdby columns tjh
-- ==========================================================================================


SELECT
  LTRIM(RTRIM(bg.id))                                   AS id,
  'Breeding'                                            AS GroupCategory,
  'Breeding grp:' + CAST(bg.breeding_grp AS VARCHAR(2)) AS GroupName,
  bg.start_date                                         AS date,
  bg.end_date                                           AS enddate,
  bg.object_id                                          AS objectid,
  bg.entry_date_tm                                      AS modified,
  dbo.f_map_username(bg.user_name)                      AS modifiedby,
  tc.created                                            AS created,
  tc.createdby                                          AS createdby,
  bg.timestamp
FROM dbo.breeding_grp AS bg
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = bg.object_id
  INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = bg.id

UNION
SELECT
  LTRIM(RTRIM(c.id))              AS id,
  'Colony'                        AS GroupCategory,
  c.colony                        AS GroupName,
  c.start_date_tm                 AS date,
  c.end_date_tm                   AS enddate,
  c.object_id                     AS objectid,
  c.entry_date_tm                 AS modified,
  dbo.f_map_username(c.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,

  c.timestamp
FROM dbo.colony AS c
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = c.object_id
  INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id

UNION
SELECT
  LTRIM(RTRIM(p.id))              AS id,
  'Pedigree'                      AS GroupCategory,
  p.pedigree                      AS GroupName,
  p.start_date                    AS date,
  p.stop_date                     AS enddate,
  p.object_id                     AS objectid,
  p.entry_date_tm                 AS modified,
  dbo.f_map_username(p.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,

  p.timestamp
FROM dbo.pedigree AS p
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = p.object_id
  INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = p.id

GO

GRANT SELECT ON labkey_etl.V_ANIMAL_GROUP_MEMBERS TO z_labkey

GO