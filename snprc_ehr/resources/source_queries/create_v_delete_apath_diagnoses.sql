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

/****** Object:  View [labkey_etl].[v_delete_apath_diagnoses] Script Date: 6/25/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_delete_apath_diagnoses] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/15
-- Description:	Rewrite of Marty's query to run as a view.
--
-- 6/25/2015 limited to selection of primates only. tjh
-- 6/29/2015 renamed. tjh
-- ==========================================================================================
SELECT ad.object_id,
	   ad.audit_date_tm

FROM apath.dbo.audit_diagnosis ad
--INNER JOIN apath.dbo.apath AS a ON a.accession_code = ad.accession_code
-- select primates only from the TxBiomed colony
--INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.animal_id
WHERE ad.audit_action IN( '0','D' ) AND ad.OBJECT_ID IS NOT NULL
  
GO

GRANT SELECT on labkey_etl.v_delete_apath_diagnoses TO z_labkey
go