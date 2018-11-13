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
ALTER VIEW [labkey_etl].[V_DELETE_ANIMAL_GROUP_CATEGORIES] as
-- ====================================================================================================================
-- Object: v_delete_animal_group_categoriess
-- Author:		Terry Hawkins
-- Create date: 2/20/2017
-- 
-- ==========================================================================================
SELECT 
	avc.object_id,
	avc.audit_date_tm

FROM audit.audit_animal_group_categories AS avc
WHERE avc.AUDIT_ACTION = 'D' AND avc.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_GROUP_CATEGORIES to z_labkey
GRANT SELECT ON audit.audit_animal_group_categories TO z_labkey

go