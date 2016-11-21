/*
 * Copyright (c) 2015 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_apath_encounters] Script Date: 6/25/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_apath_encounters] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/15
-- Description:	Rewrite of Marty's query to run as a view.
--
-- 6/25/2015 limited to selection of primates only. tjh
-- 11/4/2016 added modified, modifiedby, created, createdby columns. tjh
-- 
-- ==========================================================================================
SELECT

  a.animal_id                     AS Id,
  COALESCE(a.biopsy, a.death)     AS date,
  a.accession_num                 AS caseno,
  a.object_id                     AS objectid,
  a.entry_date_tm                 AS modified,
  dbo.f_map_username(a.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  a.timestamp,

  CASE
  WHEN vrs.description LIKE 'Pending%'
    THEN 'Review Required'
  ELSE 'Completed'
  END                             AS QCStateLabel,

  CASE
  WHEN a.tissue IS NOT NULL
    THEN (a.tissue + '-' + vac.description)
  ELSE vac.description
  END                             AS title

FROM apath.dbo.apath a
  INNER JOIN apath.dbo.valid_accession_codes vac ON a.accession_code = vac.accession_code
  INNER JOIN apath.dbo.valid_record_status vrs ON a.record_status = vrs.record_status
  LEFT OUTER JOIN apath.dbo.TAC_COLUMNS AS tc ON tc.object_id = a.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.animal_id
WHERE a.animal_id IS NOT NULL AND COALESCE(a.biopsy, a.death) IS NOT NULL AND vac.description IS NOT NULL

GO

GRANT SELECT ON labkey_etl.v_apath_encounters TO z_labkey
GO