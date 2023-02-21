-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	Copies OBX records from Sqlmed data to populate LabKey HL7 tables
-- ==========================================================================================
INSERT INTO labkey.snprc_ehr.HL7_OBX
(
    MESSAGE_ID,
    IDX,
    OBR_OBJECT_ID,
    SET_ID,
    OBR_SET_ID,
    VALUE_TYPE,
    TEST_ID,
    TEST_NAME,
    serviceTestId,
    QUALITATIVE_RESULT,
    RESULT,
    UNITS,
    REFERENCE_RANGE,
    ABNORMAL_FLAGS,
    RESULT_STATUS,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM,
	container
)
(
SELECT obx.MESSAGE_ID AS MESSAGE_ID,
       1 AS IDX,
       obr.OBJECT_ID AS OBR_OBJECT_ID,
       obx.SET_ID AS SET_ID,
       obr.SET_ID AS OBR_SET_ID,
       obx.VALUE_TYPE AS VALUE_TYPE,
       obx.TEST_ID AS TEST_ID,
       COALESCE (lp.TestName, obx.TEST_NAME) AS TEST_NAME,
       lp.OBJECT_ID AS serviceTestId,
       CAST(LTRIM(RTRIM(obx.OBSERVED_VALUE)) AS VARCHAR(MAX)) AS QUALITATIVE_RESULT,
       CASE WHEN obx.VALUE_TYPE = 'NM' AND animal.dbo.f_isNumeric(obx.OBSERVED_VALUE) = 1
                THEN CAST(LTRIM(RTRIM(REPLACE(obx.OBSERVED_VALUE, ' ', ''))) AS DECIMAL(10, 3))
            ELSE
               NULL 
			END AS RESULT,
       obx.UNITS AS UNITS,
       obx.REFERENCE_RANGE AS REFERENCE_RANGE,
       obx.ABNORMAL_FLAGS AS ABNORMAL_FLAGS,
       obx.RESULT_STATUS AS RESULT_STATUS,
       obx.OBJECT_ID AS OBJECT_ID,
       animal.dbo.f_map_username(obx.USER_NAME) AS USER_NAME,
       obx.ENTRY_DATE_TM AS ENTRY_DATE_TM,
	   c.EntityId AS container
FROM animal.dbo.CLINICAL_PATH_OBX AS obx
	INNER JOIN labkey.snprc_ehr.HL7_OBR AS obr ON obr.MESSAGE_ID = obx.MESSAGE_ID
    LEFT OUTER JOIN animal.dbo.CLINICAL_PATH_LABWORK_PANELS AS lp ON obr.PROCEDURE_ID = lp.ServiceId AND obx.TEST_ID = lp.TestId
	INNER JOIN labkey.core.Containers AS c ON c.Name = 'SNPRC'

)
