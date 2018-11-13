/*
 * Copyright (c) 2017 LabKey Corporation
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
CREATE VIEW [labkey_etl].[v_delete_snd_PkgCategoryJunction] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/28/2017
-- Description:	Selects the records to delete from snd.PkgCategoryJunction dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT ap.object_id,
	ap.audit_date_tm
FROM AUDIT.AUDIT_PKG_CATEGORY AS ap
WHERE ap.audit_action = 'D' AND ap.object_id IS NOT NULL

GO


grant SELECT on labkey_etl.v_delete_snd_PkgCategoryJunction to z_labkey
GRANT SELECT ON audit.AUDIT_PKG_CATEGORY TO z_labkey

GO