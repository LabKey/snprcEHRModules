-- panelName is UPPER/trimmed so the panel filters in ParasitologyPivotOP and ParasitologyPivot match every case/whitespace variant on Postgres.
-- TestName comes from snprc_ehr.labworkPanelTestNames to normalize inconsistent casing and whitespace in labwork_panels test names; that extra work slows this query.
SELECT
    b.Id,
    b.date,
    UPPER(RTRIM(LTRIM(b.runId.serviceRequested))) as panelName,
    n.TestName,
    b.remark,
    COALESCE(CAST(CAST(b.result AS float) AS VARCHAR), b.qualresult) as result,
    b.abnormal_flags
FROM study.labworkResults b
    LEFT OUTER JOIN snprc_ehr.labworkPanelTestNames n ON n.TestKey = UPPER(REPLACE(b.serviceTestId.testName, ' ', ''))
WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Parasitology'

UNION

SELECT
    obr.ANIMAL_ID as id,
    obr.OBSERVATION_DATE_TM as date,
    UPPER(RTRIM(LTRIM(obr.PROCEDURE_NAME))) as panelName,
    COALESCE(n.TestName, obx.TEST_NAME) as TestName,
    nte.COMMENT as remark,
    COALESCE(obx.RESULT, obx.QUALITATIVE_RESULT) as result,
    obx.ABNORMAL_FLAGS AS abnormal_flags

FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labworkPanelTestNames n ON n.TestKey = UPPER(REPLACE(obx.TEST_NAME, ' ', ''))
WHERE obr.PROCEDURE_ID.Dataset = 'Parasitology'