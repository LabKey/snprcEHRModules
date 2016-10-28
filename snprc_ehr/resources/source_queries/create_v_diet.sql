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

/****** Object:  View [labkey_etl].[V_DIET]    Script Date: 12/31/2014 2:54:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_DIET                                              */
/*==============================================================*/


ALTER VIEW [labkey_etl].[V_DIET] AS
-- ====================================================================================================================
-- Object: v_diet
-- Author:	Terry Hawkins
-- Create date: 7/15/2015
--
-- added code to end date entries with max_disposition_date. tjh 
-- ==========================================================================================

SELECT d.ID AS id, 
	d.start_date AS date,
	COALESCE(d.end_date, cd.disp_date_tm_max) AS enddate,
	'Diet' AS category,
	vd.snomed_code AS code,
	d.tid AS visitRowId,
	d.OBJECT_ID AS objectid,
	d.entry_date_tm AS modified,
	d.user_name AS user_name,
	d.TIMESTAMP
FROM dbo.diet AS d
LEFT OUTER JOIN dbo.valid_diet AS vd ON vd.diet = d.diet
-- select primates only from the TxBiomed colony
INNER JOIN current_data AS cd ON cd.id = d.id
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS v ON v.id = d.id

GO

GRANT SELECT ON labkey_etl.v_diet TO z_labkey
GO
