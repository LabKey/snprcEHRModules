SELECT obr.ANIMAL_ID as id,
       obr.OBSERVATION_DATE_TM as date,
    obr.MESSAGE_ID,
    COALESCE (lp.ServiceId.ServiceName, obr.PROCEDURE_NAME) as PROCEDURE_NAME,
    obr.PROCEDURE_ID,
    nte.COMMENT,
    COALESCE (lp.TestName, obx.TEST_NAME) as TestName,
    MAX(obx.ABNORMAL_FLAGS) AS ABNORMAL_FLAGS,
    MAX(obx.QUALITATIVE_RESULT) as QUALITATIVE_RESULT,
    MAX(obx.RESULT) as RESULT

FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = lp.ServiceId
WHERE obr.PROCEDURE_ID.Dataset = 'Culture'

GROUP BY obr.ANIMAL_ID, obr.OBSERVATION_DATE_TM, obr.MESSAGE_ID, obr.PROCEDURE_NAME, obr.SET_ID, COALESCE (lp.ServiceId.ServiceName, obr.PROCEDURE_NAME), obr.PROCEDURE_ID, nte.COMMENT, COALESCE (lp.TestName, obx.TEST_NAME)
    PIVOT QUALITATIVE_RESULT BY TestName

IN
    (
    SELECT DISTINCT TestName FROM snprc_ehr.labwork_panels t
    WHERE t.includeInPanel = true AND t.ServiceId.Dataset='Culture'
    )