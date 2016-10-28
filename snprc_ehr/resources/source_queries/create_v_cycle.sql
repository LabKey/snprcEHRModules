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
/* View: V_CYCLE                                                */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_CYCLE] AS
-- ==========================================================================================
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 8/3/2015
-- DESCRIPTION:	View provides the cycle data for LabKey
-- CHANGES:
--
-- 2/3/2016 user_name column renamed to performedby
SELECT id,
	cycle_date AS date,
	CAST(object_id AS VARCHAR(128)) + '/' + category AS objectid,
	category, 
	observation,
	user_name AS performedby,
	timestamp
FROM  ( SELECT c.id ,
          c.cycle_date ,
          CAST(c.male_status AS VARCHAR(8)) AS male_status,
          CAST(c.male_id AS VARCHAR(8) ) AS male_id ,
          CAST(c.tumescence_index AS VARCHAR(8)) AS tumescence_index,
          CAST(c.vaginal_bleeding AS VARCHAR(8)) AS vaginal_bleeding,
          CAST(c.purple_color AS VARCHAR(8)) AS purple_color,
          CAST(c.carrying_infant AS VARCHAR(8)) AS carrying_infant,
		  CAST(c.cycle_location AS VARCHAR(8)) AS cycle_location,
		  CAST(c.observer_emp_num AS VARCHAR(8)) AS observer_emp_num,
		  c.object_id,
          c.user_name ,
          c.entry_date_tm ,
          c.timestamp
         FROM cycle AS c
		-- select primates only from the TxBiomed colony
		INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id
		--WHERE c.id = ' 30910'
		 
		 ) AS p

		UNPIVOT (observation FOR category IN 
		 ( male_status, tumescence_index, vaginal_bleeding,purple_color , carrying_infant, male_id, cycle_location, observer_emp_num)) AS u

GO

GRANT SELECT ON Labkey_etl.V_CYCLE TO z_labkey
GO