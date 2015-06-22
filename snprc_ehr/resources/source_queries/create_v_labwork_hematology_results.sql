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

/****** Object:  View [labkey_etl].[v_labwork_hematology_results]    Script Date: 2/5/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_labwork_hematology_results] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/19/2015
-- Description:	Selects the hematology ETL records for LabKey study.labwork_results dataset
-- Note:  Currently only selecting the following data types:
--			CBC
-- Changes:
--
-- 6/19/2015 Removed spaces from observed_value string before converting to a decimal. tjh
-- ==========================================================================================


SELECT obr.ANIMAL_ID AS id,
	   obr.OBSERVATION_DATE_TM AS date,
	   NULL AS project,
	   obx.TEST_ID AS testid,
	   '' AS resultOORIndicator,
	   obx.VALUE_TYPE AS value_type,
	   obx.TEST_NAME AS test_name,
	   CASE WHEN obx.VALUE_TYPE = 'NM' AND dbo.f_isNumeric(obx.OBSERVED_VALUE) = 1
			THEN CAST( LTRIM(RTRIM(REPLACE(obx.OBSERVED_VALUE, ' ', ''))) AS DECIMAL(10,3)) ELSE NULL END AS result,
	   obx.OBSERVED_VALUE AS qualresult,
	   obx.UNITS AS units,
	   obx.REFERENCE_RANGE AS refRange,
	   obx.ABNORMAL_FLAGS AS abnormal_flags,

 		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							( SELECT
								RTRIM(LTRIM(nte.comment)) + '**NEWLINE**'
									FROM  dbo.CLINICAL_PATH_NTE AS nte
									WHERE nte.message_id = obr.message_id AND obx.set_id = nte.set_id
									ORDER BY CAST(nte.set_id AS INTEGER)
									FOR XML PATH('')				-- generates a concatenation of result set (for an xml doc)

							),
						'**NEWLINE**', CHAR(13)+CHAR(10) ),
					 '**TAB**', SPACE(4)),
					'&gt;', '>'),
			 '&lt;', '<'),
		 '&amp;', '&')

		 AS remark,
	   '' AS description,
	   obx.object_id AS object_id,
	   obx.MESSAGE_ID AS runid,		-- foreign key to obr rows
	   '' AS parent_id,
	   '' AS taskid,
	   obx.USER_NAME AS performedby,
	   '' AS requestedid,
	  -- obx.ENTRY_DATE_TM AS enddate,
	   '' AS method
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID

WHERE  (obr.PROCEDURE_NAME LIKE '%differential only%' OR obr.PROCEDURE_NAME LIKE '%CBC%')
  AND (obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
  AND obr.RESULT_STATUS = 'F'

AND obx.TEST_ID  IN (1,7,2,3,4,5,6,62,54,649,858,630,608,11,13,14,9,8,643,803,644,800,801,
										  647,802,646,648,768, 650,798,651,652,653,654,642,655,656,660,657,658,659,
										  706, 770,797,771,772,773,774,796,799, 592, 713)

--AND obr.VERIFIED_DATE_TM >= '1/1/2014 00:00'

GO


grant SELECT on [labkey_etl].[v_labwork_hematology_results] to z_labkey
grant SELECT on [labkey_etl].[v_labwork_hematology_results] to z_camp_base

go
