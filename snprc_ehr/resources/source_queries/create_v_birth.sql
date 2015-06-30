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
/* View: V_BIRTH                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_BIRTH] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/1/2015
-- Description:	Selects the ETL records for LabKey study.birth dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	m.id AS id, 
	m.birth_date AS date, 
	m.bd_status AS date_type,
	--m.dam_id AS dam,
	--m.sex AS gender,
	--LOWER(avs.common_name) AS species, 
	--m.sire_id AS sire,
	m.entry_date_tm AS entry_date_tm,
	m.user_name AS user_name,
	m.object_id AS objectid,
	m.timestamp as timestamp
FROM master m
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = m.id
WHERE m.birth_date IS NOT null

GO

GRANT SELECT ON Labkey_etl.v_birth TO z_labkey 

GO

