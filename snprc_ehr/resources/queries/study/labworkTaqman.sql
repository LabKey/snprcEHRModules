SELECT
    tr.participantid AS Id,
    tr.date,
    0 AS project,
    lp.ServiceId,
    lp.ObjectId AS serviceTestId,
    lp.TestId,
    NULL AS resultOORIndicator,
    'TX' AS value_type,
    NULL AS result,
    NULL AS units,
    tr.SWBV AS qualresult,
    NULL AS refRange,
    NULL AS abnormal_flags,
    tr.objectId AS runid,
    NULL AS enddate,
    NULL AS method,
    'From Excel import' AS remark,
    tr.history AS history,
    tr.lsid,
    tr.Sequencenum,
    tr.qcstate
FROM study.taqmanresults AS tr
         INNER JOIN snprc_ehr.labwork_panels AS lp ON lp.ServiceId = 20000 AND lp.testName = 'SWBV'
         INNER JOIN snprc_ehr.labwork_services AS ls ON ls.ServiceId = lp.ServiceId

UNION

SELECT
    tr.participantid AS Id,
    tr.date,
    0 AS project,
    lp.ServiceId,
     lp.ObjectId AS serviceTestId,
    lp.TestId,
    NULL AS resultOORIndicator,
    'TX' AS value_type,
    NULL AS result,
    NULL AS units,
    tr.STLV1 AS qualresult,
    NULL AS refRange,
    NULL AS abnormal_flags,
    tr.objectId AS runid,
    NULL AS enddate,
    NULL AS method,
    'From Excel import',
    tr.history AS history,
    tr.lsid,
    tr.Sequencenum,
    tr.qcstate
FROM study.taqmanresults AS tr
         INNER JOIN snprc_ehr.labwork_panels AS lp ON lp.ServiceId = 20000 AND lp.testName = 'STLV1'
         INNER JOIN snprc_ehr.labwork_services AS ls ON ls.ServiceId = lp.ServiceId
