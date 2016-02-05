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
/* View: V_OBSERVATIONS                                                */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_OBSERVATIONS] AS
-- ==========================================================================================
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 1/15/2016
-- DESCRIPTION:	View provides the observation data for LabKey
-- CHANGES:
-- 2/3/2016 user_name column renamed to performedby
--

SELECT id, 
	obs_date AS date, 
	CAST(object_id AS VARCHAR(128)) + '/' + category AS objectid,
	category, 
	CAST(observation AS VARCHAR(3)) AS observation,
	user_name AS performedby,
	timestamp 
FROM (SELECT id, obs_date,
	CAST(water AS VARCHAR(3) ) AS water, CAST(feed  AS VARCHAR(3) ) AS feed,
	CAST(sa_none AS VARCHAR(3) ) AS sa_none,  CAST(sa_bloody AS VARCHAR(3)) AS sa_bloody,
	CAST(sa_dry AS VARCHAR(3) ) AS sa_dry, CAST(sa_loose AS VARCHAR(3) ) AS sa_loose,
	CAST(sa_normal AS VARCHAR(3) ) AS sa_normal, CAST(sa_other AS VARCHAR(3) ) AS sa_other,
	CAST(sa_pellet AS VARCHAR(3) ) AS sa_pellet,
	CAST(sa_soft AS VARCHAR(3) ) AS sa_soft, CAST(sa_unknown AS VARCHAR(3) ) AS sa_unknown, 
	CAST(sa_watery  AS VARCHAR(3) ) AS sa_watery, 
	CAST(housing_status AS VARCHAR(3)) AS housing_status,
	o.object_id,
    o.user_name ,
    o.entry_date_tm ,
    o.timestamp
 FROM observations AS o
 WHERE housing_status IS NOT NULL)
  --and id = ' 15149')
AS result 
UNPIVOT
(
  observation FOR category   IN (water, feed , sa_none, sa_bloody, sa_dry, sa_loose,
	sa_normal, sa_other, sa_pellet, sa_soft, sa_unknown, sa_watery, housing_status)
	)
	AS Unpvt

GO 
	
GRANT SELECT ON Labkey_etl.V_OBSERVATIONS TO z_labkey
GO