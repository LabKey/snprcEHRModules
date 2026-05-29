/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--
-- Description: This view is a wrapper for the table-valued function fGetAllSuperPkgs
--
CREATE VIEW [labkey_etl].[v_sndGetAllSuperPkgs] AS
(
    SELECT * FROM labkey_etl.fGetAllSuperPkgs()
);
GO

GRANT SELECT ON Labkey_etl.v_sndGetAllSuperPkgs TO z_labkey
GO