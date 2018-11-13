/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
CREATE VIEW [labkey_etl].[V_DELETE_valid_species] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/23/2015
-- Description:	Selects the ETL records for LabKey snprc_ehr.valid_species dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT
	avs.object_id,
	avs.audit_date_tm
FROM audit.audit_valid_species AS avs
WHERE avs.audit_action = 'D' AND avs.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_valid_species TO z_labkey
GRANT SELECT ON audit.audit_valid_species TO z_labkey

GO
