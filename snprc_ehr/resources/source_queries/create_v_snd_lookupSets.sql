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

Alter VIEW [labkey_etl].[v_snd_lookupSets] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/16/2018
-- Description:	Used as source for the Lookup table dataset ETL
-- Note:
--
-- Changes:
--
--
-- ==========================================================================================
SELECT 
  pkl.LOOKUP_KEY as [SetName],
  pkl.OBJECT_ID AS [objectid],
  pkl.ENTRY_DATE_TM AS [modified],
  dbo.f_map_username(pkl.USER_NAME) AS [modifiedby],
  tc.created AS [created],
  tc.createdby AS [createdby],
  pkl.TIMESTAMP
FROM dbo.PKG_ATTRIB_LOOKUPS pkl
  
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
    ON tc.object_id = pkl.OBJECT_ID

go

GRANT SELECT ON [labkey_etl].[v_snd_lookupSets] TO z_labkey
GO

