/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE VIEW snprc_ehr.HL7_GroupNTE AS
SELECT
    a.OBR_OBJECT_ID,
    a.OBR_SET_ID,
    a.Container,
    STRING_AGG(a.comment, CHR(10) ORDER BY a.SET_ID ASC) AS comment
FROM
    (
        SELECT COALESCE(CAST(n.comment AS TEXT), '') AS comment,
               n.OBR_OBJECT_ID AS OBR_OBJECT_ID,
               n.OBR_SET_ID AS OBR_SET_ID,
               n.set_id,
               n.Container
        FROM snprc_ehr.HL7_NTE n
    ) AS a
GROUP BY a.OBR_OBJECT_ID, a.OBR_SET_ID, a.Container;
