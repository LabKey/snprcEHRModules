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

/****** Object:  View [labkey_etl].[v_delete_clinical_admissions]    Script Date: 6/26/2015 10:59:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [labkey_etl].[v_delete_clinical_admissions] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the clinical admissions for LabKey study.clinical_observations dataset for deletions
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT ac.object_id AS objectid,
	   ac.audit_date_tm AS audit_date_tm



FROM audit.audit_clinic AS ac
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ac.id
WHERE ac.audit_action = 'D' AND ac.object_id IS NOT NULL


GO

grant SELECT on [labkey_etl].[v_delete_clinical_admissions] to z_labkey
GRANT SELECT ON [audit].[audit_clinic] TO z_labkey
go
