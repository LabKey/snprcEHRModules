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

/****** Object:  View [labkey_etl].[v_iacuc_protocols]    Script Date: 2/8/2017 4:10:07 PM ******/
SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO



ALTER VIEW [labkey_etl].[v_location_temperature] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date:	02/05/2019
-- Description:	Selects the location_temperature date LabKey ehr.protocol dataset
-- Note:
--	Temps are numeric(6,2)
--	
-- Changes:
-- 02/26/2019  added TAC columns...
-- ==========================================================================================

SELECT lt.location			AS	Room,
       lt.date_tm			AS	Date,
       lt.low_temperature	AS	LowTemperature,
       lt.high_temperature	AS	HighTemperature,
       lt.notify			AS	Notify,
       lt.object_id			AS objectid,
	     lt.entry_date_tm		AS	modified,
       dbo.f_map_username(lt.user_name) AS modifiedby,
       tc.created       AS created,
       tc.createdby     AS createdby,
       lt.timestamp			AS timestamp
FROM dbo.location_temperature lt
       LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
                       ON tc.object_id = lt.object_id
GO

GRANT SELECT ON [labkey_etl].[v_location_temperature] TO z_labkey

  GO