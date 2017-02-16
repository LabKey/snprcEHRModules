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

ALTER VIEW labkey_etl.v_lab_tests AS
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
  til.test_type                     AS type,
  til.test_id                       AS testid,
  til.test_name                     AS name,
  til.units                         AS units,
  0                                 AS alertOnAbnormal,
  0                                 AS alertOnAny,
  1                                 AS includeInPanel,
  til.sort_order                    AS sort_order,
  til.object_id                     AS objectid,
  til.entry_date_tm                 AS modified,
  dbo.f_map_username(til.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,
  til.timestamp
FROM dbo.CLINICAL_PATH_TEST_ID_LOOKUP AS til
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = til.object_id
GO

GRANT SELECT ON labkey_etl.v_lab_tests TO z_labkey

GO