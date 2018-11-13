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
USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_package_category_junction] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/23/2015
-- Description:	relates package_ids to category_ids.
-- Note:
--
-- Changes:
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
--
-- ==========================================================================================


SELECT
  pc.TID                           AS rowId,
  pc.pkg_id                        AS packageId,
  CAST(vct.code AS INT)            AS categoryId,
  pc.object_id                     AS objectid,
  pc.entry_date_tm                 AS modified,
  dbo.f_map_username(pc.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  pc.timestamp                     AS timestamp
FROM dbo.PKG_CATEGORY AS pc
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = pc.object_id
  INNER JOIN valid_code_table AS vct ON pc.CATEGORY_CODE = vct.CODE
                                        AND vct.TABLE_NAME = 'pkg_category'
                                        AND vct.COLUMN_NAME = 'category_code'
                                        AND vct.END_DATE_TM IS NULL


GO
GRANT SELECT ON [labkey_etl].[v_package_category_junction] TO z_labkey

GO
