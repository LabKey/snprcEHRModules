-- TestName comes from snprc_ehr.labworkPanelTestNames to normalize inconsistent casing and whitespace in labwork_panels test names; that extra work slows this query.
SELECT
    p.Id as Id,
    p.date,
    UPPER(RTRIM(LTRIM(p.runId.serviceRequested))) as PanelName,
    n.TestName,
    p.remark,
    UPPER(RTRIM(LTRIM(p.qualresult))) as result,
    p.abnormal_flags

FROM study.labworkResults as p
    LEFT OUTER JOIN snprc_ehr.labworkPanelTestNames n ON n.TestKey = UPPER(REPLACE(p.serviceTestId.testName, ' ', ''))
WHERE p.serviceTestId.includeInPanel = true AND p.serviceTestid.ServiceId.Dataset ='Culture'

UNION

SELECT
    obr.ANIMAL_ID as id,
    obr.OBSERVATION_DATE_TM as date,
    UPPER(RTRIM(LTRIM(COALESCE(lp.ServiceId.ServiceName, obr.PROCEDURE_NAME)))) as PanelName,
    COALESCE(n.TestName, UPPER(RTRIM(LTRIM(obx.TEST_NAME)))) as TestName,
    nte.COMMENT as remark,
    UPPER(RTRIM(LTRIM(COALESCE(obx.RESULT, obx.QUALITATIVE_RESULT)))) as result,
    obx.ABNORMAL_FLAGS AS abnormal_flags

FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = CAST(lp.ServiceId AS VARCHAR)
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labworkPanelTestNames n ON n.TestKey = UPPER(REPLACE(COALESCE(lp.TestName, obx.TEST_NAME), ' ', ''))
WHERE obr.PROCEDURE_ID.Dataset = 'Culture'
