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

/****** Object:  View [labkey_etl].[v_labwork_surveillance_results]    Script Date: 2/5/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_labwork_surveillance_results] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/19/2015
-- Description:	Selects the hematology ETL records for LabKey study.labwork_results dataset 
-- Note:  Currently only selecting the following data types:
--			Surveillance
-- Changes:
--
-- 6/19/2015 Removed spaces from observed_value string before converting to a decimal. tjh
-- 8/28/2015 Normalized T. CRUZI results and reference range.  tjh
-- 11/11/2016  added modified, modifiedby, created, and createdby columns + code cleanup tjh
-- ==========================================================================================


SELECT
  obr.ANIMAL_ID                     AS id,
  obr.OBSERVATION_DATE_TM           AS date,
  NULL                              AS project,
  obx.TEST_ID                       AS testid,
  ''                                AS resultOORIndicator,
  obx.VALUE_TYPE                    AS value_type,
  obx.TEST_NAME                     AS test_name,
  CASE WHEN obx.VALUE_TYPE = 'NM' AND dbo.f_isNumeric(obx.OBSERVED_VALUE) = 1
    THEN CAST(LTRIM(RTRIM(REPLACE(obx.OBSERVED_VALUE, ' ', ''))) AS DECIMAL(10, 3))
  ELSE NULL END                     AS result,
  -- 850 = T. CRUZI AB 876 = T.CRUZI BY PCR
  CASE WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE = 'SEROPOS')
    THEN 'POSITIVE'
  WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE = 'SERONEG')
    THEN 'NEGATIVE'
  WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE = 'IND')
    THEN 'INDETERMINATE'
  ELSE obx.OBSERVED_VALUE END       AS qualresult,
  obx.UNITS                         AS units,
  CASE WHEN (test_id IN (850, 876))
    THEN 'NEGATIVE'
  ELSE obx.REFERENCE_RANGE END      AS refRange,
  obx.ABNORMAL_FLAGS                AS abnormal_flags,
  CASE WHEN obx.test_name = obx.observed_value
    THEN --LIKE ('%comment%') then
      REPLACE(
          REPLACE(
              REPLACE(
                  REPLACE(
                      REPLACE(
                          (SELECT obx2.OBSERVED_VALUE + ' **' + '**NEWLINE**'
                           FROM dbo.CLINICAL_PATH_OBX AS obx2
                           WHERE obx2.message_id = obr.message_id
                                 AND
                                 (obx2.test_name LIKE '%comment%'
                                  OR obx2.test_name LIKE '%:%'
                                  OR obx2.test_name LIKE '%testing performed%'
                                  OR obx2.test_name LIKE '%lab memo%'
                                  OR obx2.test_name LIKE '%source%')
                           ORDER BY CAST(obx2.set_id AS INTEGER)
                           FOR XML PATH ('')),
                          '**NEWLINE**', CHAR(13) + CHAR(10)),
                      '**TAB**', SPACE(4)),
                  '&gt;', '>'),
              '&lt;', '<'),
          '&amp;', '&')
  ELSE '' END

                                    AS remark,
  ''                                AS description,
  obx.MESSAGE_ID                    AS runid,
  -- foreign key to obr rows
  ''                                AS parent_id,
  ''                                AS taskid,
  ''                                AS requestedid,
  ''                                AS method,
  obx.object_id                     AS objectid,
  obx.entry_date_tm                 AS modified,
  dbo.f_map_username(obx.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,

  obx.TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr
  JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.animal_id
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obx.object_id

WHERE obr.PROCEDURE_name IN (SELECT PROCEDURE_name
                             FROM clinical_path_proc_id_lookup
                             WHERE procedure_type = 'Surveillance')
--       AND obx.test_id IN (SELECT test_id
--                           FROM dbo.CLINICAL_PATH_TEST_ID_LOOKUP AS lu
--                           WHERE lu.test_type = 'Surveillance')
      AND (obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
      AND obr.RESULT_STATUS = 'F'

GO


GRANT SELECT ON [labkey_etl].[v_labwork_surveillance_results] TO z_labkey
GO