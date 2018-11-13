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
/* View: V_DELETE_PACKAGE_CATEGORY_JUNCTION                     */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_PACKAGE_CATEGORY_JUNCTION] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/30/2015
-- Description:	Selects the ETL records for LabKey snprc_ehr.package_category_junction dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================
SELECT ap.object_id,
	ap.audit_date_tm
FROM AUDIT.AUDIT_PKG_CATEGORY AS ap
WHERE ap.audit_action = 'D' AND ap.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.V_DELETE_PACKAGE_CATEGORY_JUNCTION to z_labkey
GRANT SELECT ON audit.AUDIT_PKG_CATEGORY TO z_labkey

GO