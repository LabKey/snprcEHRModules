/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**************************************************



 **************************************************/


ALTER VIEW [labkey_etl].[v_valid_dx_list] AS
-- ====================================================================================================================
-- Object: v_valid_dx_list
-- Author:		Scott Rouse
-- Create date: 07/11/2019
-- Changes:
--
-- ==========================================================================================
SELECT vd.dx_group                      AS DXGroup,
       vd.dx                            AS DX,
       vd.dx_status                     AS DXStatus,
       vd.object_id                     AS ObjectId,
       vd.entry_date_tm                 AS modified,
       dbo.f_map_username(vd.user_name) AS modifiedby,
	   COALESCE(tc.created, vd.entry_date_tm )  AS created,
	   COALESCE(tc.createdby, dbo.f_map_username(vd.user_name)) AS createdby,
       vd.timestamp
FROM dbo.valid_dx_list vd
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vd.object_id
 
GO

GRANT SELECT ON labkey_etl.v_valid_dx_list TO z_labkey

GO
