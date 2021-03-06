/*
 * Copyright (c) 2015-2019 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_iacuc_protocols]    Script Date: 2/8/2017 4:10:07 PM ******/
SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO



ALTER VIEW [labkey_etl].[v_iacuc_protocols] AS
    /*-- ==========================================================================================
  -- Author:		Terry Hawkins
  -- Create date: 6/23/2015
  -- Description:	Selects the IACUC master data for LabKey ehr.protocol dataset
  -- Note:
  --
  -- Changes:
  -- 11/11/2016  added modified, modifiedby, created, and createdby columns + code cleanup tjh
  -- 11/21/2016  exclude protocols with a status of withdrawn, pending, or deferred tjh
  -- 12/30/2016  usda_level changed to max_usda_use_code column. tjh
  -- 04/14/2017   Use arc_master object id exclusively. tjh
  -- 09/28/2018   added veterinarian column. tjh
  -- 05/1/2019   use f_IACUC_num_animals_approved to get maxAnimals value,
					3yr approval date, last_modification, first_approval
  -- 07/17/20	Added outer join to valid_colony_maintenance_iacuc and brought in flag for
					maintenance/housing protocol type, M.  Non-maintenance protocols get type R.
                    project_type in LabkeySpeak
                    Populate Extensible column sequenceNumber with IACUC base number (arc_num_seq) srr
   ==========================================================================================*/


SELECT
    am.working_iacuc                          AS protocol,
    ad.title                                  AS title,
    ad.pi_name                                AS inves,
    typ.start_date							  AS approve,		-- 3yr approval date
    ad.approval_date                          AS last_modification,
    ad2.approval_date						  AS first_approval,
    am.termination_date                       AS enddate,
    am.arc_num_seq								AS sequenceNumber, -- Base IACUC number
    COALESCE(m.iacuc_type,'R')				AS project_type,   -- Maintenance or Research
    dbo.f_IACUC_num_animals_approved(am.working_iacuc, ad.approval_date)          AS maxAnimals,
    ad.max_usda_use_code AS usda_level,
    ad.supervising_vet AS veterinarian,
    am.object_id							AS objectid,
    CASE WHEN am.timestamp > ad.timestamp
             THEN am.entry_date_tm
         ELSE ad.entry_date_tm END                 AS modified,
    CASE WHEN am.timestamp > ad.timestamp
             THEN dbo.f_map_username(am.user_name)
         ELSE dbo.f_map_username(ad.user_name) END AS modifiedby,
    tc.created                                AS created,
    tc.createdby                              AS createdby,
    CASE WHEN am.timestamp > ad.timestamp
             THEN am.timestamp
         ELSE ad.timestamp END                     AS timestamp

FROM dbo.arc_master AS am
         INNER JOIN dbo.arc_detail AS ad
                    ON ad.arc_num_seq = am.arc_num_seq
                        AND ad.arc_num_genus = am.arc_num_genus
                        AND ad.arc_num_amendment = (SELECT MAX(ad.arc_num_amendment)
                                                    FROM arc_detail AS ad
                                                    WHERE ad.arc_num_seq = am.arc_num_seq
                                                      AND ad.arc_num_genus = am.arc_num_genus)
                        AND ad.application_status = 'A'
         LEFT OUTER JOIN dbo.valid_colony_maintenance_iacuc AS M
                         ON am.working_iacuc = m.working_iacuc
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
                         ON tc.object_id = (SELECT CASE WHEN am.timestamp > ad.timestamp
                                                            THEN am.object_id ELSE ad.object_id END AS object_id)
         LEFT JOIN dbo.v_IACUC_3yr_periods AS typ
                   ON typ.working_iacuc = am.working_iacuc
                       AND typ.[3yr_period] = (SELECT MAX([3yr_period])
									FROM dbo.v_IACUC_3yr_periods
									WHERE working_iacuc = am.working_iacuc)
		INNER JOIN dbo.arc_detail AS ad2
ON ad2.arc_num_seq = am.arc_num_seq
    AND ad2.arc_num_genus = am.arc_num_genus
    AND ad2.arc_num_amendment = 0
WHERE ad.application_status = 'A' -- exclude those with a status of withdrawn, pending, or deferred.

    GO
GRANT SELECT ON [labkey_etl].[v_iacuc_protocols] TO z_labkey

GO
