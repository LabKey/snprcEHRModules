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
    Container,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM
)
(
SELECT obx.MESSAGE_ID AS MESSAGE_ID,
       1 AS IDX,
       obr.OBJECT_ID as OBR_OBJECT_ID,
       obx.SET_ID AS SET_ID,
       obr.SET_ID AS OBR_SET_ID,
       obx.VALUE_TYPE AS VALUE_TYPE,
       obx.TEST_ID AS TEST_ID,
       COALESCE (lp.TestName, obx.TEST_NAME) as TEST_NAME,
       c.EntityId as Container,
       lp.OBJECT_ID AS serviceTestId,
       CAST(LTRIM(RTRIM(obx.OBSERVED_VALUE)) as VARCHAR(MAX)) as QUALITATIVE_RESULT,
       CASE WHEN obx.VALUE_TYPE = 'NM' AND dbo.f_isNumeric(obx.OBSERVED_VALUE) = 1
                THEN CAST(LTRIM(RTRIM(REPLACE(obx.OBSERVED_VALUE, ' ', ''))) AS DECIMAL(10, 3))
            ELSE
               NULL 
			END AS RESULT,
       obx.UNITS AS UNITS,
       obx.REFERENCE_RANGE AS REFERENCE_RANGE,
       obx.ABNORMAL_FLAGS AS ABNORMAL_FLAGS,
       obx.RESULT_STATUS AS RESULT_STATUS,
       obx.OBJECT_ID AS OBJECT_ID,
       dbo.f_map_username(obx.USER_NAME) AS USER_NAME,
       obx.ENTRY_DATE_TM AS ENTRY_DATE_TM
FROM dbo.CLINICAL_PATH_OBX AS obx

    -- select primates only from the TxBiomed colony
    INNER JOIN dbo.CLINICAL_PATH_OBR as obr on obx.MESSAGE_ID = obr.MESSAGE_ID
    INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
    LEFT OUTER JOIN dbo.CLINICAL_PATH_LABWORK_PANELS AS lp ON obr.PROCEDURE_ID = lp.ServiceId AND obx.TEST_ID = lp.TestId
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obx.OBJECT_ID
    INNER JOIN labkey.core.Containers AS c on c.name = 'SNPRC'
WHERE obx.RESULT_STATUS IN ( 'F', 'C', 'D' )
	AND obr.VERIFIED_DATE_TM IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM labkey_etl.v_delete_labwork_results AS dclr WHERE obx.OBJECT_ID = dclr.objectid)
)