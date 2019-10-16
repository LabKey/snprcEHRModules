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

/****** Object:  View [labkey_etl].[v_delete_charge_account]    Script Date: 6/26/2015 10:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_charge_account] AS
  -- ==========================================================================================
  -- Author:		Terry Hawkins
  -- Create date: 6/22/2015
  -- Description:	Selects the charge_account data for LabKey ehr.project dataset
  -- Note:
  --
  -- Changes:
  -- 11/11/2016  added modified, modifiedby, created, and createdby columns tjh
  --
  -- ==========================================================================================


  SELECT
    ca.charge_id                     AS project,
	CASE WHEN vcs.charge_id IS NULL THEN 'True' ELSE 'False' END AS research,
    ca.cost_account                  AS account,
    ca.working_iacuc                 AS protocol,
	coalesce(right(ca.working_iacuc, 2), vcs.arc_species_code) as species,
    ca.start_date                    AS startdate,
    ca.stop_date                     AS enddate,
    ca.short_description             AS shortName,
    ca.long_description              AS name,
    ca.object_id                     AS objectid,
    ca.entry_date_tm                 AS modified,
    dbo.f_map_username(ca.user_name) AS modifiedby,
    tc.created                       AS created,
    tc.createdby                     AS createdby,
    ca.timestamp                     AS timestamp
  FROM dbo.charge_account AS ca
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ca.object_id
	LEFT OUTER JOIN dbo.valid_charge_by_species AS vcs ON ca.charge_id = vcs.charge_id


GO
GRANT SELECT ON [labkey_etl].[v_charge_account] TO z_labkey

--GO
