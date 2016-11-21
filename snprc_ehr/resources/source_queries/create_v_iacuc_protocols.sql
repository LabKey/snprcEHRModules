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

/****** Object:  View [labkey_etl].[v_iacuc_protocols]    Script Date: 6/23/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_iacuc_protocols] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/2015
-- Description:	Selects the IACUC master data for LabKey ehr.protocol dataset
-- Note: 
--		
-- Changes:
-- 11/11/2016  added modified, modifiedby, created, and createdby columns + code cleanup tjh
-- 11/21/2016  exclude protocols with a status of withdrawn, pending, or deferred tjh
--
-- ==========================================================================================


SELECT
  am.working_iacuc                          AS protocol,
  ad.review_date                            AS lastAnnualReview,
  ad.title                                  AS title,
  ad.pi_name                                AS inves,
  ad.approval_date                          AS approve,
  am.termination_date                       AS enddate,

  CASE WHEN am.timestamp > ad.timestamp
    THEN am.object_id
  ELSE ad.object_id END                     AS object_id,

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
  INNER JOIN dbo.arc_detail AS ad ON ad.arc_num_seq = am.arc_num_seq AND ad.arc_num_genus = am.arc_num_genus AND
                                     ad.arc_num_amendment = (SELECT MAX(ad.arc_num_amendment)
                                                             FROM arc_detail AS ad
                                                             WHERE ad.arc_num_seq = am.arc_num_seq
                                                                   AND ad.arc_num_genus = am.arc_num_genus)
																   AND ad.application_status = 'A'
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = (SELECT CASE WHEN am.timestamp > ad.timestamp
    THEN am.object_id ELSE ad.object_id END AS object_id)

	WHERE ad.application_status = 'A' -- exclude those with a status of withdrawn, pending, or deferred.


GO

GRANT SELECT ON [labkey_etl].[v_iacuc_protocols] TO z_labkey

GO