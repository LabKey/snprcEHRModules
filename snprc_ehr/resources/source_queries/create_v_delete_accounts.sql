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
/* View: V_DELETE_ACCOUNTS                                      */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_ACCOUNTS] as
-- ====================================================================================================================
-- Object: v_audit_accounts
-- Author:		Terry Hawkins
-- Create date: 6/12/2015
--
-- 6/29/2015 renamed. tjh
-- 7/2/2021 changed demographics data source. tjh
-- ==========================================================================================
SELECT 
	aa.object_id,
	aa.audit_date_tm

FROM audit.audit_accounts AS aa
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.v_demographics_for_delete AS d ON d.id = aa.id
WHERE aa.AUDIT_ACTION = 'D' AND aa.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.V_DELETE_ACCOUNTS to z_labkey
GRANT SELECT ON audit.audit_accounts TO z_labkey


go
