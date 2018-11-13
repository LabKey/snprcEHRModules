/*
 * Copyright (c) 2016 LabKey Corporation
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
CREATE VIEW [labkey_etl].[V_DELETE_VALID_INSTITUTIONS] AS
-- ====================================================================================================================
-- Object: v_delete_valid_institutions
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- ==========================================================================================
SELECT
	avi.object_id,
	avi.audit_date_tm

FROM audit.audit_valid_institutions AS avi
WHERE avi.AUDIT_ACTION = 'D' AND avi.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.V_DELETE_VALID_INSTITUTIONS TO z_labkey
GRANT SELECT ON audit.audit_valid_institutions TO z_labkey

GO