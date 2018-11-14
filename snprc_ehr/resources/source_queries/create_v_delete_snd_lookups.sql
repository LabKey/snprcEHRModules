/*
 * Copyright (c) 2018 LabKey Corporation
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
CREATE VIEW [labkey_etl].[v_delete_snd_lookups] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 01/30/2018
-- Description:	Used as source for the deleting lookups dataset ETL
-- Note: Sourced from v_delete_valid_institutions
--
-- Changes:
--
--
-- ==========================================================================================
SELECT al.OBJECT_ID,
  al.AUDIT_DATE_TM
FROM audit.AUDIT_LOOKUP_TABLE al
WHERE al.AUDIT_ACTION = 'D'
      AND al.OBJECT_ID IS NOT NULL



GO

--

GRANT SELECT ON labkey_etl.V_delete_snd_lookups TO z_labkey;
GRANT SELECT ON audit.AUDIT_LOOKUP_TABLE TO z_labkey;
go
