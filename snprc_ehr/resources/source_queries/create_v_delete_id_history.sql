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
/* View: V_DELETE_ID_HISTORY                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_ID_HISTORY] as
-- ====================================================================================================================
-- Author:		Terry Hawkins
-- Create date: 7/30/2015
--
-- Changes:
-- 7/2/2021 changed demographics data source. tjh
-- ==========================================================================================
SELECT 
	aih.object_id,
	aih.audit_date_tm

FROM audit.audit_id_history AS aih
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.v_demographics_for_delete AS d ON d.id = aih.sfbr_id
WHERE aih.AUDIT_ACTION = 'D' AND aih.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.V_DELETE_ID_HISTORY to z_labkey
GRANT SELECT ON audit.audit_id_history TO z_labkey

go
