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

/****** Object:  View [labkey_etl].[V_ANIMAL_GROUPS]    Script Date: 8/28/2015 5:00:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: v_animal_groups                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_GROUPS] AS
-- ====================================================================================================================
-- Object: v_animal_groups
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
--
-- 3/1/2016	Added pedigree data. tjh
-- 3/3/2016 Added account_group. tjh
-- 11/4/2016 added modified, modifiedby, created, createdby columns. tjh
-- ==========================================================================================


SELECT
  'Breeding grp:' + CAST(vbg.breeding_grp AS VARCHAR(2)) AS name,
  'Breeding'                                             AS category,
  vbg.description                                        AS comment,
  vbg.ori_date                                           AS date,
  vbg.close_date                                         AS enddate,
  vbg.object_id                                          AS objectid,
  vbg.entry_date_tm                                      AS modified,
  dbo.f_map_username(vbg.user_name)                      AS modifiedby,
  tc.created                                             AS created,
  tc.createdby                                           AS createdby,
  vbg.timestamp
FROM dbo.valid_breeding_grps AS vbg
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vbg.object_id

UNION
SELECT
  c.colony                        AS name,
  'Colony'                        AS category,
  c.description                   AS comment,
  c.ori_date                      AS date,
  c.close_date                    AS enddate,
  c.object_id                     AS objectid,
  c.entry_date_tm                 AS modified,
  dbo.f_map_username(c.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  c.timestamp
FROM dbo.valid_colonies AS c
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = c.object_id

UNION
SELECT
  vp.pedigree                      AS name,
  'Pedigree'                       AS category,
  vp.description                   AS comment,
  vp.entry_date_tm                 AS date,
  NULL                             AS enddate,
  vp.object_id                     AS objectid,
  vp.entry_date_tm                 AS modified,
  dbo.f_map_username(vp.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  vp.timestamp
FROM dbo.valid_pedigrees AS vp
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vp.object_id


GO

GRANT SELECT ON labkey_etl.V_ANIMAL_GROUPS TO z_labkey

GO