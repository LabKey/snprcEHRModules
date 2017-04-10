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

/****** Object:  View [labkey_etl].[V_DELETE_DEATH]    Script Date: 6/26/2015 10:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_DEATH                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_DEATH] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.birth dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT am.object_id,
	am.audit_date_tm
FROM audit.audit_master AS am
INNER JOIN dbo.master as m on m.id = am.id
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = am.id
WHERE am.audit_action = 'D' 
  OR
	 (m.death_date is null and am.death_date IS null
		AND am.audit_timestamp = (SELECT MAX(audit_timestamp) FROM audit.audit_master WHERE id = am.id)
  )
  AND am.object_id IS NOT NULL
GO

GRANT SELECT ON Labkey_etl.V_DELETE_DEATH TO z_labkey 
GRANT SELECT ON audit.audit_acq_disp TO z_labkey
GRANT SELECT ON dbo.master TO z_labkey
GO

