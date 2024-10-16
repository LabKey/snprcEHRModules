/*
 * Copyright (c) 2015-2017 LabKey Corporation
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


ALTER VIEW Labkey_etl.v_clinPathRuns AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/08/2015
-- Description:	Selects the ETL records for LabKey study.clinPathRuns dataset
-- Changes:
-- 11/10/2016 added modified, modifiedby, created, and createdby columns + code cleanup tjh
-- 6/16/2017  added serviceId and commented out serviceRequested and animalVisit. tjh
-- 6/19/2017  casted dateFinalized to a datetime2 to round time up to seconds. tjh
-- 6/20/2017  dateFinalized is managed in ehr\triggers.js by LK.  Created new column (verifiedDate) to
--			  store the verified date. tjh
-- 7/25/2017  removed message_id - data moved to objectid column.
-- 10/15/2021 service name lookup moved to dbo.CLINICAL_PATH_LABWORK_SERVICES table
-- ==========================================================================================
SELECT
  obr.animal_id                                                AS Id,
  obr.OBSERVATION_DATE_TM                                      AS Date,
  --obr.message_id                                               AS message_id,
  cast(cast(obr.verified_date_tm AS DATETIME2(0)) AS DATETIME) AS verifiedDate,
  obr.SPECIMEN_NUM                                             AS sampleId,
  lu.ServiceName        									   AS serviceRequested,
  obr.PROCEDURE_ID                                             AS serviceId,
  --  obr.PV1_VISIT_NUM										   AS animalVisit,
  obr.message_id                                                AS objectid,
  obr.entry_date_tm                                            AS modified,
  dbo.f_map_username(obr.user_name)                            AS modifiedby,
  tc.created                                                   AS created,
  tc.createdby                                                 AS createdby,
  obr.TIMESTAMP                                                AS timestamp
FROM dbo.CLINICAL_PATH_OBR AS obr

  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
  INNER JOIN dbo.CLINICAL_PATH_LABWORK_SERVICES AS lu ON obr.procedure_id = lu.ServiceId
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obr.object_id

WHERE obr.RESULT_STATUS IN ('F', 'C', 'D')
      AND obr.VERIFIED_DATE_TM IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_clinPathRuns TO z_labkey
GRANT SELECT ON dbo.CLINICAL_PATH_LABWORK_SERVICES TO z_labkey

GO
