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

/*==============================================================*/
/* View: V_DELETE_BIRTH                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_BIRTH] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.birth dataset which need to be deleted
-- Changes:
-- 7/2/2021 changed demographics data source. tjh
--
-- ==========================================================================================

SELECT am.object_id,
	am.audit_date_tm
FROM audit.audit_master AS am
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.v_demographics_for_delete AS d ON d.id = am.id
WHERE am.audit_action = 'D' AND am.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.V_DELETE_BIRTH TO z_labkey 
GRANT SELECT ON audit.audit_acq_disp TO z_labkey

GO

