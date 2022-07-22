SELECT
    obr.ANIMAL_ID as id,
    obr.OBSERVATION_DATE_TM as date,
    obr.MESSAGE_ID,
    obr.PROCEDURE_NAME,
    obr.PROCEDURE_ID,
    nte.COMMENT,
    obx.TEST_NAME,
    MAX(obx.ABNORMAL_FLAGS) AS ABNORMAL_FLAGS,
    MAX(obx.QUALITATIVE_RESULT) as QUALITATIVE_RESULT,
    MAX(obx.RESULT) as RESULT

FROM snprc_ehr.HL7_OBR obr
LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
LEFT OUTER JOIN snprc_ehr.HL7_NTE nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
WHERE obr.PROCEDURE_ID.Dataset = 'Hematology'

GROUP BY obr.ANIMAL_ID, obr.OBSERVATION_DATE_TM, obr.MESSAGE_ID, obr.PROCEDURE_NAME, obr.SET_ID, obr.PROCEDURE_NAME, obr.PROCEDURE_ID, nte.COMMENT, obx.TEST_NAME
PIVOT RESULT, QUALITATIVE_RESULT, ABNORMAL_FLAGS BY TEST_NAME

-- IN
--     (
--      select TestName as TEST_NAME from snprc_ehr.labwork_panels t
--      where t.includeInPanel = true AND t.ServiceId.Dataset='Hematology'
--     )