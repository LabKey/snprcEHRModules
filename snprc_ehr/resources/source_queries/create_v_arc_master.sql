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

/****** Object:  View [labkey_etl].[v_arc_master]    Script Date: 6/23/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_arc_master] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/23/2015
-- Description:	Selects the IACUC master data for LabKey ehr.protocol dataset
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT am.working_iacuc AS protocol,
	ad.review_date AS lastAnnualReview,
	ad.title AS title, 
	ad.pi_name AS inves,
	ad.approval_date AS approve,
	am.termination_date AS enddate,
	am.user_name AS user_name,
	am.entry_date_tm AS entry_date_tm,
	am.object_id AS objectid, 
	am.timestamp AS timestamp
FROM dbo.arc_master AS am
JOIN dbo.arc_detail AS ad ON ad.arc_num_seq = am.arc_num_seq AND ad.arc_num_genus = am.arc_num_genus AND
	ad.arc_num_amendment = (SELECT MAX(ad.arc_num_amendment) 
							FROM arc_detail AS ad
							WHERE ad.arc_num_seq = am.arc_num_seq 
							  AND ad.arc_num_genus = am.arc_num_genus)

GO

grant SELECT on [labkey_etl].[v_arc_master] to z_labkey
grant SELECT on [labkey_etl].[v_arc_master] to z_camp_base

go
