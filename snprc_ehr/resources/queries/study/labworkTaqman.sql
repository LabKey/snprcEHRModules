/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    tr.participantid AS Id,
    tr.date,
    0 AS project,
    lp.ServiceId,
    lp.ObjectId AS serviceTestId,
    lp.TestId,
    NULL AS resultOORIndicator,
    'TX' AS value_type,
    CAST(NULL AS DOUBLE) AS result,
    NULL AS units,
    tr.SWBV AS qualresult,
    NULL AS refRange,
    NULL AS abnormal_flags,
    tr.objectId AS runid,
    CAST(NULL AS TIMESTAMP) AS enddate,
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
    CAST(NULL AS DOUBLE) AS result,
    NULL AS units,
    tr.STLV1 AS qualresult,
    NULL AS refRange,
    NULL AS abnormal_flags,
    tr.objectId AS runid,
    CAST(NULL AS TIMESTAMP) AS enddate,
    NULL AS method,
    'From Excel import' AS remark,
    tr.history AS history,
    tr.lsid,
    tr.Sequencenum,
    tr.qcstate
FROM study.taqmanresults AS tr
         INNER JOIN snprc_ehr.labwork_panels AS lp ON lp.ServiceId = 20000 AND lp.testName = 'STLV1'
         INNER JOIN snprc_ehr.labwork_services AS ls ON ls.ServiceId = lp.ServiceId
