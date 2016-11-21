/*
 * Copyright (c) 2016 LabKey Corporation
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

ALTER VIEW [labkey_etl].[V_REMARKS] AS
  -- ==========================================================================================
  -- Author:		Terry Hawkins
  -- Create date: 5/23/2016
  -- Description:	Used as source for the notes dataset ETL
  -- Note:
  --
  -- Changes:
  -- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
  --
  -- ==========================================================================================

  SELECT
    r.ID                            AS id,
    r.remark_date                   AS date,
    r.remark                        AS remark,
    r.OBJECT_ID                     AS objectid,
    r.entry_date_tm                 AS modified,
    dbo.f_map_username(r.user_name) AS modifiedby,
    tc.created                      AS created,
    tc.createdby                    AS createdby,
    r.TIMESTAMP
  FROM dbo.remarks AS r
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = r.object_id
    -- select primates only from the TxBiomed colony
    INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS v ON v.id = r.id

GO

GRANT SELECT ON labkey_etl.v_remarks TO z_labkey
GO

