/*
 * Copyright (c) 2017-2018 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_delete_apath_pathology] Script Date: 6/25/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_delete_apath_pathology] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/15
-- Description:	Rewrite of Marty's query to run as a view.
--
-- 6/25/2015 limited to selection of primates only. tjh
-- 6/29/2015 renamed 
-- 5/23/2017 renamed (again).
-- ==========================================================================================
SELECT a.object_id,
      a.audit_date_tm

FROM apath.dbo.audit_apath a
INNER JOIN apath.dbo.valid_accession_codes vac ON a.accession_code = vac.accession_code
INNER JOIN apath.dbo.valid_record_status vrs ON a.record_status = vrs.record_status

-- select primates only from the txbiomed colony
INNER JOIN master AS m ON m.id = a.animal_id
INNER JOIN valid_species vs ON m.species = vs.species_code
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
INNER JOIN current_data AS cd ON m.id = cd.id
INNER JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'
  AND a.audit_action IN ('0', 'D') AND a.OBJECT_ID IS NOT NULL
  
GO

GRANT SELECT on labkey_etl.v_delete_apath_pathology TO z_labkey

go