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
alter VIEW [labkey_etl].[v_delete_snd_lookupSets] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/16/2018
-- Description:	Used as source for the deleting lookupSets dataset ETL
-- Note: Sourced from v_delete_lookup_table
--
-- Changes:
--
--
-- ==========================================================================================
SELECT pkl.OBJECT_ID,
  pkl.AUDIT_DATE_TM
FROM audit.AUDIT_PKG_ATTRIB_LOOKUPS pkl
WHERE pkl.AUDIT_ACTION = 'D'
      AND pkl.OBJECT_ID IS NOT NULL

GO

--

GRANT SELECT ON labkey_etl.v_delete_snd_lookupSets TO z_labkey;
GRANT SELECT ON audit.AUDIT_PKG_ATTRIB_LOOKUPS TO z_labkey;
go
