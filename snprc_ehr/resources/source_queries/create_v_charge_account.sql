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

/****** Object:  View [labkey_etl].[v_charge_account]    Script Date: 2/5/2015 8:51:28 AM ******/
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
--
-- ==========================================================================================


SELECT ca.charge_id AS project,
	ca.cost_account AS account,
	ca.working_iacuc AS protocol,
	ca.start_date AS startdate,
	ca.stop_date AS enddate,
	ca.short_description AS shortName,
	ca.long_description AS name,
	ca.user_name AS user_name,
	ca.entry_date_tm AS entry_date_tm,
	ca.object_id AS objectid, 
	ca.timestamp AS timestamp
FROM dbo.charge_account AS ca

GO

grant SELECT on [labkey_etl].[v_charge_account] to z_labkey
grant SELECT on [labkey_etl].[v_charge_account] to z_camp_base

go
