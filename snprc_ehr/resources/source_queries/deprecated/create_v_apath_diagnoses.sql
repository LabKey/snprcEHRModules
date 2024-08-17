/*
 * Copyright (c) 2015-2017 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_apath_diagnoses] Script Date: 6/25/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_apath_diagnoses] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/15
-- Description:	Rewrite of Marty's query to run as a view.
--
-- 6/25/2015 limited to selection of primates only. tjh
-- 11/4/2016 added modified, modifiedby, created, createdby columns. tjh
-- 5/23/2017 tweaked column sources. tjh
-- ==========================================================================================
SELECT

  a.animal_id                     AS Id,
  d.accession_num                 AS AccessionNumber,
  COALESCE(a.biopsy, a.death)     AS date,
  d.object_id                     AS objectid,
  d.entry_date_tm                 AS modified,
  dbo.f_map_username(d.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  d.morphology,
  d.organ,
  d.etiology_code,
  d.sp_etiology,
  d.timestamp

FROM apath.dbo.diagnosis d
  INNER JOIN apath.dbo.apath a ON d.accession_num = a.accession_num
  LEFT OUTER JOIN apath.dbo.TAC_COLUMNS AS tc ON tc.object_id = d.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d2 ON d2.id = a.animal_ID
WHERE d.unique_it IS NOT NULL AND COALESCE(a.biopsy, a.death) IS NOT NULL

GO

GRANT SELECT ON labkey_etl.v_apath_diagnoses TO z_labkey
GO