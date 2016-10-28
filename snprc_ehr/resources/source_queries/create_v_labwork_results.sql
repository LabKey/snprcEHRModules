/*
 * Copyright (c) 2016 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_labwork_results]    Script Date: 2/5/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/4/2016
-- Description:	Merged surveillance, hematology, and biochemistry into a single view for the 
--                  labkey ETL.
-- ==========================================================================================

ALTER VIEW [labkey_etl].[v_labwork_results] AS
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
			-- 850 = T. CRUZI AB 876 = T.CRUZI BY PCR
	   CASE WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE ='SEROPOS') THEN 'POSITIVE'
	        WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE = 'SERONEG') THEN 'NEGATIVE'
			WHEN (test_id IN (850, 876) AND obx.OBSERVED_VALUE = 'IND') THEN 'INDETERMINATE' 
			ELSE obx.OBSERVED_VALUE END AS qualresult,
	   obx.UNITS AS units,
	   CASE WHEN (test_id IN (850, 876)) THEN 'NEGATIVE' ELSE obx.REFERENCE_RANGE END AS refRange,
	   obx.ABNORMAL_FLAGS AS abnormal_flags,
	   CASE WHEN obx.test_name = obx.observed_value THEN --LIKE ('%comment%') then 
 		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							( SELECT obx2.OBSERVED_VALUE + ' **' + '**NEWLINE**'
								FROM  dbo.CLINICAL_PATH_OBX AS obx2
								WHERE obx2.message_id = obr.message_id 
									AND
									(obx2.test_name LIKE '%comment%' 
									OR obx2.test_name LIKE '%:%' 
									OR obx2.test_name LIKE '%testing performed%'
									OR obx2.test_name LIKE '%lab memo%'
									OR obx2.test_name LIKE '%source%')
								ORDER BY CAST(obx2.set_id AS INTEGER)
								FOR XML PATH('')), 
						'**NEWLINE**', CHAR(13)+CHAR(10) ),
					 '**TAB**', SPACE(4)),
					'&gt;', '>'),
			 '&lt;', '<'),
		 '&amp;', '&')
		 ELSE '' END 
			 
		 AS remark,
	   '' AS description,
	   obx.object_id AS object_id,
	   obx.MESSAGE_ID AS runid,		-- foreign key to obr rows
	   '' AS parent_id,
	   '' AS taskid,
	   obx.USER_NAME AS user_name,
	   '' AS requestedid,
	   obx.ENTRY_DATE_TM AS entry_date_tm,
	   '' AS method,
	   obx.TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.animal_id

--JOIN dbo.CLINICAL_PATH_PROC_ID_LOOKUP AS PLU ON obr.PROCEDURE_ID = plu.procedure_id AND plu.procedure_type = 'Surveillance'
--WHERE  (obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
--  AND obr.RESULT_STATUS = 'F'


WHERE obr.PROCEDURE_name IN (SELECT PROCEDURE_name FROM clinical_path_proc_id_lookup WHERE procedure_type = 'Surveillance')
	AND 
	
	--(--obx.test_name NOT LIKE '%comment%' 
	--obx.test_name NOT LIKE '%testing performed by%'
	--AND obx.TEST_NAME NOT LIKE '%lab memo%'
	--AND obx.test_name NOT LIKE '%source%'
	--) 

	--AND 
	(obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
    AND obr.RESULT_STATUS = 'F'



UNION

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
	   obx.USER_NAME AS user_name,
	   '' AS requestedid,
	  obx.ENTRY_DATE_TM AS entry_date_tm,
	   '' AS method,
	   obx.TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.animal_id

WHERE obr.PROCEDURE_name IN (SELECT PROCEDURE_name FROM clinical_path_proc_id_lookup WHERE procedure_type = 'Hematology')
	AND 	(obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
  AND obr.RESULT_STATUS = 'F'
  AND obx.TEST_ID  IN (SELECT test_id FROM dbo.CLINICAL_PATH_TEST_ID_LOOKUP AS c WHERE c.test_type = 'Hematology')

--WHERE  (obr.PROCEDURE_NAME LIKE '%differential only%' OR obr.PROCEDURE_NAME LIKE '%CBC%')
--  AND (obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
--  AND obr.RESULT_STATUS = 'F'

--AND obx.TEST_ID  IN (1,7,2,3,4,5,6,62,54,649,858,630,608,11,13,14,9,8,643,803,644,800,801,
--										  647,802,646,648,768, 650,798,651,652,653,654,642,655,656,660,657,658,659,
--										  706, 770,797,771,772,773,774,796,799, 592, 713)

--AND obr.VERIFIED_DATE_TM >= '1/1/2014 00:00'

UNION

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/22/2015
-- Description:	Selects the ETL records for LabKey study.labwork_results dataset 
-- Note:  Currently only selecting the following data types:
--			Biochemistry
-- Changes:
--
-- 6/19/2015 Removed spaces from observed_value string before converting to a decimal. tjh
-- 12/16/2015 Fixed CHEM 2 code. tjh
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
	   obx.USER_NAME AS user_name,
	   '' AS requestedid,
	  obx.ENTRY_DATE_TM AS entry_date_tm,
	   '' AS method,
	   obx.TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr
INNER JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.animal_id
--WHERE  --obr.PROCEDURE_id IN (10200, 10201, 10626)
--	obr.PROCEDURE_ID IN
--    (SELECT lu.PROCEDURE_ID FROM CLINICAL_PATH_PROC_ID_LOOKUP AS lu WHERE lu.PROCEDURE_TYPE = 'Biochemistry')
--	AND obx.test_id IN (141,205,60,612, 135,136,137,138,142,272,90,139,17,18,19,631,632,611,
--										  87,81,633,86,140, 143,77 )

WHERE obr.PROCEDURE_name IN (SELECT PROCEDURE_name FROM clinical_path_proc_id_lookup WHERE procedure_type = 'Biochemistry')
	AND 	(obx.RESULT_STATUS = 'F' OR obx.RESULT_STATUS = 'C')
  AND obr.RESULT_STATUS = 'F'
  AND obx.TEST_ID  IN (SELECT test_id FROM dbo.CLINICAL_PATH_TEST_ID_LOOKUP AS c WHERE c.test_type = 'Biochemistry')

GO


GRANT SELECT ON [labkey_etl].[v_labwork_results]  TO z_labkey
GRANT SELECT ON dbo.CLINICAL_PATH_PROC_ID_LOOKUP TO z_labkey
grant SELECT on [labkey_etl].[v_labwork_results] to z_camp_base

GO