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

/****** Object:  View [dbo].[Labkey_etl.v_clinPathRuns]    Script Date: 1/8/2015 4:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW Labkey_etl.v_clinPathRuns AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/08/2015
-- Description:	Selects the ETL records for LabKey study.clinPathRuns dataset 
-- Note:  Currently only selecting the following data types:
--			Hematology
--			Biochemistry
-- Changes:
--
--
-- ==========================================================================================
SELECT obr.animal_id AS [Id],
	   obr.OBSERVATION_DATE_TM AS [Date],
	   obr.message_id AS [objectId],
	   obr.verified_date_tm as [dateFinalized],
	   obr.SPECIMEN_NUM AS [sampleId], 
	   obr.PROCEDURE_NAME AS [serviceRequested],
	   obr.PV1_VISIT_NUM AS [animalVisit],
	   obr.ENTRY_DATE_TM AS [created],
	   obr.USER_NAME AS [createdBy]
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
WHERE (obr.PROCEDURE_NAME LIKE '%differential only%' 
	 OR obr.PROCEDURE_NAME LIKE '%CBC%' 
	 OR  obr.PROCEDURE_id IN (10200, 10201, 106262) )
  AND obr.RESULT_STATUS = 'F'
  AND obr.VERIFIED_DATE_TM >= '1/1/2014 00:00'

GO

GRANT SELECT ON Labkey_etl.v_clinPathRuns TO z_camp_base
GO

