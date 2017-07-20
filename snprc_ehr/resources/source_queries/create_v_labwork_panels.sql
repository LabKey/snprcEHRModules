/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW labkey_etl.v_labwork_panels AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 5/6/2016
-- Description:	selects data for the snprc_ehr.lab_tests lookup table
-- Changes:
-- 11/11/2016  added modified, modifiedby, created, and createdby columns + code cleanup tjh
--
--
-- ==========================================================================================
SELECT
  lp.RowID                         AS RowId,
  lp.ServiceId                     AS ServiceId,
  lp.TestId                        AS TestId,
  lp.TestName                      AS TestName,
  lp.Units                         AS Units,
  0                                AS AlertOnAbnormal,
  0                                AS AlertOnAny,
  1                                AS IncludeInPanel,
  lp.SortOrder                     AS SortOrder,
  lp.object_id                     AS ObjectId,
  lp.entry_date_tm                 AS Modified,
  dbo.f_map_username(lp.user_name) AS Modifiedby,
  tc.Created                       AS Created,
  tc.Createdby                     AS Createdby,
  lp.timestamp
FROM dbo.CLINICAL_PATH_LABWORK_PANELS AS lp
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = lp.object_id
GO

GRANT SELECT ON labkey_etl.v_labwork_panels TO z_labkey

GO