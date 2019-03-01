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

ALTER VIEW [labkey_etl].[V_FLAG_VALUES] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 3/28/2016
-- Description:	Used as source for the flag_values ETL
-- Note:
--
-- Changes:
-- 2/18/2019 rewrite tjh
-- ==========================================================================================

SELECT
       va.category AS category,
	   va.attribute AS value,
       va.attribute_desc AS description,
       va.code AS code,
	   va.display_order AS sort_order,
       va.object_id AS objectId,
       va.entry_date_tm                 AS modified,
       dbo.f_map_username(va.user_name) AS modifiedby,
       tc.created                       AS created,
       tc.createdby                     AS createdby,
       va.timestamp AS timestamp
FROM dbo.valid_attributes AS va
 LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = va.object_id

GO
grant SELECT on [labkey_etl].[v_flag_values] to z_labkey

go

