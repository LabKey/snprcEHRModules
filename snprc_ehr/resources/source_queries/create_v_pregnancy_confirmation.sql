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

ALTER VIEW [labkey_etl].[V_pregnancy_confirmation] AS
-- ====================================================================================================================
-- Author: Terry Hawkins
-- Create date: 8/31/2015
--
-- Changes:
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
-- ==========================================================================================


SELECT
  edc.id                            AS id,
  edc.edc                           AS date,
  LTRIM(RTRIM(edc.sire_id))         AS sire,
  edc.term_date                     AS termDate,
  edc.term_code                     AS termCode,
  edc.confirm_date                  AS confirmDate,
  edc.last_obscan_date              AS lastObscanDate,
  edc.object_id                     AS objectid,
  edc.entry_date_tm                 AS modified,
  dbo.f_map_username(edc.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,
  edc.timestamp
FROM dbo.edc AS edc
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = edc.object_id
  INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = edc.id


GO

GRANT SELECT ON labkey_etl.V_PREGNANCY_CONFIRMATION TO z_labkey

GO