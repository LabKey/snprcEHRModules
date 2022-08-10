SELECT
    p.Id as Id,
    p.date,
    p.serviceTestId.testName as TestName,
    p.runId.serviceRequested as PanelName,
    p.remark,
    p.qualresult as result

FROM study.labworkResults as p
WHERE p.serviceTestId.includeInPanel = true AND p.serviceTestid.ServiceId.Dataset ='Culture'

UNION

SELECT
    obr.ANIMAL_ID as id,
    obr.OBSERVATION_DATE_TM as date,
    COALESCE (lp.ServiceId.ServiceName, obr.PROCEDURE_NAME) as PanelName,
    COALESCE (lp.TestName, obx.TEST_NAME) as TestName,
    nte.COMMENT as remark,
    COALESCE(obx.RESULT, obx.QUALITATIVE_RESULT) as result

FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = lp.ServiceId
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
WHERE obr.PROCEDURE_ID.Dataset = 'Culture'
