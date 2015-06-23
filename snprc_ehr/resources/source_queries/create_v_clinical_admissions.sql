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

/****** Object:  View [labkey_etl].[v_clinical_admissions]    Script Date: 2/5/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create VIEW [labkey_etl].[v_clinical_admissions] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/22/2015
-- Description:	Selects the clinical admissions for LabKey study.clinical_observations dataset
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT c.id AS id,
	   c.admit_date_tm AS date, 
	   LTRIM(RTRIM(c.id)) + CAST(c.admit_id AS VARCHAR(128)) AS ParticipantSequenceNum,
	   c.release_date_tm AS enddate,
	   'PDX: ' + RTRIM(LTRIM(c.pdx)) + '; Resolution: ' + c.resolution AS observation,
	   c.admit_complaint AS remark,
	   CAST(c.admit_id AS INTEGER) AS visitRowId,
	   c.charge_id AS project,
	   c.vet_name AS performedby,
	   c.admit_code AS code,
	   c.user_name AS modifiedby,
	   c.entry_date_tm AS modified,
	   c.object_id AS objectid,
	   c.timestamp AS timestamp



FROM dbo.clinic AS c
GO



grant SELECT on [labkey_etl].[v_clinical_admissions] to z_labkey
grant SELECT on [labkey_etl].[v_clinical_admissions] to z_camp_base

go
