/*
 * Copyright (c) 2019 LabKey Corporation
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
/* View: V_OBSERVATIONS                                                */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_OBSERVATIONS] AS
-- ==========================================================================================
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 1/15/2016
-- DESCRIPTION:	View provides the observation data for LabKey
-- CHANGES:
-- 2/3/2016 user_name column renamed to performedby
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
--

SELECT
  id,
  obs_date                                         AS date,
  CAST(object_id AS VARCHAR(128)) + '/' + category AS objectid,
  category,
  CAST(observation AS VARCHAR(80))                 AS observation,
  modified,
  modifiedby,
  created,
  createdby,
  timestamp
FROM (SELECT
        id,
        obs_date,
        CAST(water AS VARCHAR(80))          AS water,
        CAST(feed AS VARCHAR(80))           AS feed,
        CAST(sa_none AS VARCHAR(80))        AS sa_none,
        CAST(sa_bloody AS VARCHAR(80))      AS sa_bloody,
        CAST(sa_dry AS VARCHAR(80))         AS sa_dry,
        CAST(sa_loose AS VARCHAR(80))       AS sa_loose,
        CAST(sa_normal AS VARCHAR(80))      AS sa_normal,
        CAST(sa_other AS VARCHAR(80))       AS sa_other,
        CAST(sa_pellet AS VARCHAR(80))      AS sa_pellet,
        CAST(sa_soft AS VARCHAR(80))        AS sa_soft,
        CAST(sa_unknown AS VARCHAR(80))     AS sa_unknown,
        CAST(sa_watery AS VARCHAR(80))      AS sa_watery,
        CAST(housing_status AS VARCHAR(80)) AS housing_status,
        CAST(comments AS VARCHAR(80))       AS comments,
        o.object_id,
        o.entry_date_tm                     AS modified,
        dbo.f_map_username(o.user_name)     AS modifiedby,
        tc.created                          AS created,
        tc.createdby                        AS createdby,
        o.timestamp
      FROM observations AS o
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = o.object_id

)
AS result
UNPIVOT
(
observation FOR category IN (water, feed, sa_none, sa_bloody, sa_dry, sa_loose,
sa_normal, sa_other, sa_pellet, sa_soft, sa_unknown, sa_watery, housing_status, comments)
)
AS Unpvt

GO

GRANT SELECT ON Labkey_etl.V_OBSERVATIONS TO z_labkey
GO