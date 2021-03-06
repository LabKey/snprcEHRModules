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

ALTER VIEW [labkey_etl].[v_arc_animal_assignments] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 8/14/2015
-- Description:	Selects the arc_animal_assignments for the LabKey dataset
-- Note: 
--		
-- Changes:
-- 11/4/2016  added modified, modifiedby, created, and createdby columns tjh
--
-- ==========================================================================================

SELECT
  aaa.id,
  aaa.start_date                    AS date,
  aaa.end_date                      AS enddate,
  aaa.arc_num_seq,
  aaa.arc_num_genus,
  aaa.working_iacuc                 AS protocol,
  aaa.status                        AS assignmentStatus,
  aaa.comments                      AS remark,
  aaa.object_id                     AS objectid,
  aaa.user_name,
  aaa.entry_date_tm,
  aaa.entry_date_tm                 AS modified,
  dbo.f_map_username(aaa.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,

  aaa.timestamp                     AS timestamp

FROM dbo.arc_animal_assignments AS aaa
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = aaa.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aaa.id
GO

GRANT SELECT ON labkey_etl.v_arc_animal_assignments TO z_labkey
GO


