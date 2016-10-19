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
	m.death_code AS cause,
	m.object_id AS objectid,
	COALESCE((SELECT MIN(am.entry_date_tm) 
									FROM audit.audit_master AS am
									WHERE m.id = am.id), m.entry_date_tm) AS created,
	m.entry_date_tm AS modified,
	m.user_name AS user_name,
	m.timestamp AS timestamp
FROM master m
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = m.id

WHERE m.death_date IS NOT null

GO

GRANT SELECT ON Labkey_etl.v_deaths TO z_labkey
GRANT SELECT ON audit.audit_master TO z_labkey
GO

