USE [animal]
GO

/****** Object:  View [labkey_etl].[v_labwork_chemistry_results]    Script Date: 1/8/2015 4:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_labwork_chemistry_results] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/22/2015
-- Description:	Selects the ETL records for LabKey study.labwork_results dataset 
-- Note:  Currently only selecting the following data types:
--			Biochemistry
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
	   '' AS method
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN dbo.CLINICAL_PATH_OBX AS obx ON obx.MESSAGE_ID = obr.MESSAGE_ID

WHERE  obr.PROCEDURE_id IN (10200, 10201, 106262)

AND obx.test_id IN (141,205,60,612, 135,136,137,138,142,272,90,139,17,18,19,631,632,611,
										  87,81,633,86,140, 143,77 ) 
--AND obr.VERIFIED_DATE_TM >= '1/1/2014 00:00'
GO


grant SELECT on labkey_etl.v_labwork_chemistry_results to z_labkey
grant SELECT on labkey_etl.v_labwork_chemistry_results to z_camp_base

go