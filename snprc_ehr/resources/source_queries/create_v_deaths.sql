/*
 * Copyright (c) 2015 LabKey Corporation
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

/****** Object:  View [labkey_etl].[V_BIRTH]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DEATHS		                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DEATHS] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/2/2015
-- Description:	Selects the ETL records for LabKey study.deaths dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	m.id AS id, 
	m.death_date AS date, 
	m.dd_status AS date_type,
	vdc.description AS cause,
	m.object_id AS objectid,
	m.entry_date_tm AS modified,
	m.user_name AS modifiedby
FROM master m 
INNER JOIN valid_disp_codes AS vdc ON m.death_code = vdc.disp_code
INNER JOIN valid_species vs ON m.species = vs.species_code 
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
JOIN current_data AS cd ON m.id = cd.id
JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'
AND m.death_date IS NOT null

GO

GRANT SELECT ON Labkey_etl.v_deaths TO z_labkey 
GO

