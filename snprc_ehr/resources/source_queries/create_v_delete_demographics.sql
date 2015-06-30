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

/****** Object:  View [labkey_etl].[V_DELETE_DEATH]    Script Date: 6/26/2015 11:11:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_DELETE_DEMOGRAPHICS                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_DEMOGRAPHICS] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.demographics dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT am.object_id,
	am.audit_date_tm
FROM audit.audit_master AS am

WHERE am.audit_action = 'D' AND am.object_id IS NOT NULL


GO


grant SELECT on labkey_etl.V_DELETE_DEMOGRAPHICS to z_labkey
GRANT SELECT ON audit.audit_master TO z_labkey

GO