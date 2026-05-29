/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE VIEW dbo.v_sndFixNumericAttributes AS
(
    SELECT DISTINCT
        pa.ATTRIB_ID,
        pa.ATTRIB_KEY,
        'double' AS DATA_TYPE
    FROM dbo.CODED_PROC_ATTRIBS AS cpa
    INNER JOIN dbo.PKG_ATTRIBS AS pa ON pa.ATTRIB_KEY = cpa.ATTRIB_KEY
    WHERE pa.DATA_TYPE = 'numeric' AND cpa.VALUE LIKE '%.%'
)
GO

GRANT SELECT ON dbo.v_sndFixNumericAttributes TO z_labkey
GO