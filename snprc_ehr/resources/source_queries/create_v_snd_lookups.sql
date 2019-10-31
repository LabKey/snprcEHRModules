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

ALTER VIEW [labkey_etl].[v_snd_lookups] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 01/29/2018
-- Description:	Used as source for the Lookup table dataset ETL
-- Note:
--
-- Changes:
--02/16/2018 Changed IS_HIDDEN to displayable
--
-- ==========================================================================================
SELECT lt.LOOKUP_ID as [LookupId],
  lt.LOOKUP_KEY as [SetName],
  lt.VALUE,
  CASE WHEN lt.IS_HIDDEN = 'N' THEN 1 ELSE 0 END AS Displayable,
  lt.ORDER_NUM,
  lt.DEFAULT_FLAG,
  lt.OBJECT_ID AS [objectid],
  lt.ENTRY_DATE_TM AS [modified],
  dbo.f_map_username(lt.USER_NAME) AS [modifiedby],
  tc.created AS [created],
  tc.createdby AS [createdby],
  lt.TIMESTAMP

FROM [dbo].[LOOKUP_TABLE] lt
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = lt.object_id

go

GRANT SELECT ON [labkey_etl].[v_snd_lookups] TO z_labkey
GO

