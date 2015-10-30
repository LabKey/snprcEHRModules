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
/* View: V_DELETE_PACKAGE_CATEGORY                                        */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_PACKAGE_CATEGORY] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/30/2015
-- Description:	
-- Changes:
--
--
-- ==========================================================================================
SELECT av.object_id,
	av.audit_date_tm
FROM AUDIT.AUDIT_VALID_CODE_TABLE AS av

WHERE av.audit_action = 'D' AND av.object_id IS NOT NULL
  AND   av.TABLE_NAME = 'pkg_category'
  AND av.COLUMN_NAME = 'category_code'

GO


grant SELECT on labkey_etl.V_DELETE_PACKAGE_CATEGORY to z_labkey
GRANT SELECT ON audit.AUDIT_VALID_CODE_TABLE TO z_labkey

GO