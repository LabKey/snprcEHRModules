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

/****** Object:  View [labkey_etl].[v_clinical_admissions]    Script Date: 8/14/2015 8:08:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_clinical_admissions] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/22/2015
-- Description:	Selects the clinical admissions for LabKey study.clinical_observations dataset
-- Note: 
--		
-- Changes:
-- 9/25/2015	Removed animal id from ParticipantSequenceNum. tjh
--
-- ==========================================================================================


SELECT c.id AS id,
	   c.admit_date_tm AS date, 
	   CAST(c.admit_id AS VARCHAR(128)) AS ParticipantSequenceNum,
	   c.release_date_tm AS enddate,
	   c.pdx AS problem,
	   c.sdx AS sdx,
	   c.admit_complaint AS admitcomplaint,
	   c.admit_id AS caseid,
	   c.admit_code AS category,
	   c.charge_id AS project,
	   c.vet_name AS vetreviewer,  -- this should be assigned vet; however, we are missing the ehr_lookup.veterinarians table
	   c.user_name AS user_name,
	   c.entry_date_tm AS entry_date_tm,
	   c.object_id AS objectid,
	   c.timestamp AS timestamp



FROM dbo.clinic AS c
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id


GO


grant SELECT on [labkey_etl].[v_clinical_admissions] to z_labkey

go
