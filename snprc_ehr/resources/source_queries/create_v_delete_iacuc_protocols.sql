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

/****** Object:  View [labkey_etl].[v_delete_iacuc_protocols]    Script Date: 6/26/2015 11:40:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_delete_iacuc_protocols] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the IACUC master data for LabKey ehr.protocol dataset for delete
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT 	am.object_id AS objectid, 
		am.audit_date_tm

FROM audit.audit_arc_master AS am
JOIN dbo.arc_detail AS ad ON ad.arc_num_seq = am.arc_num_seq AND ad.arc_num_genus = am.arc_num_genus AND
	ad.arc_num_amendment = (SELECT MAX(ad.arc_num_amendment) 
							FROM arc_detail AS ad
							WHERE ad.arc_num_seq = am.arc_num_seq 
							  AND ad.arc_num_genus = am.arc_num_genus)
WHERE am.audit_action = 'D' AND am.object_id IS NOT NULL
GO

grant SELECT on [labkey_etl].[v_delete_iacuc_protocols] to z_labkey
GRANT SELECT ON [audit].[audit_arc_master] TO z_labkey

go
