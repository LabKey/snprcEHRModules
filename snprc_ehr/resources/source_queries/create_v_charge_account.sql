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

/****** Object:  View [labkey_etl].[v_delete_charge_account]    Script Date: 6/26/2015 10:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_delete_charge_account] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the charge_account data for LabKey ehr.project dataset for deletes
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT aca.object_id AS objectid, 
		aca.audit_date_tm
FROM audit.audit_charge_account AS aca
WHERE aca.audit_action = 'D' AND aca.OBJECT_ID IS NOT NULL
GO

grant SELECT on [labkey_etl].[v_delete_charge_account] to z_labkey
grant SELECT on [audit].[audit_charge_account] to z_labkey

go
