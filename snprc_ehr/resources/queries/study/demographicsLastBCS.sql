/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
    p.id as Id,
    p.date as BcsDate,
    p.procNarrative as LastBCS,
    p.QCState

FROM study.procedure AS p
WHERE p.qcstate.publicdata = true
AND p.pkgId.categories like '%BCS%'
and p.date = (select max(p2.date) from study.procedure as p2
                where p2.id = p.id and p2.pkgId.categories like '%BCS%')
