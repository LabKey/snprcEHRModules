/*
 * Copyright (c) 2015-2018 LabKey Corporation
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


ALTER VIEW [labkey_etl].[v_package] AS
  -- ==========================================================================================
  -- Author:		Terry Hawkins
  -- Create date: 10/23/2015
  -- Description:	selects the pkgs data
  -- Note:
  --
  -- Changes:
  -- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
  -- 4/16/2018   added pkg_type column (P=primitive, S=super-package)
  -- ==========================================================================================


  SELECT
    p.PKG_ID                        AS id,
    LEFT(p.DESCRIPTION, 100)        AS name,
    p.NARRATIVE                     AS description,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.SUPER_PKGS AS sp2
      WHERE sp2.PARENT_PKG_ID = p.PKG_ID) THEN 'S' ELSE 'P' END AS pkgType,

    p.object_id                     AS objectid,
    p.entry_date_tm                 AS modified,
    dbo.f_map_username(p.user_name) AS modifiedby,
    tc.created                      AS created,
    tc.createdby                    AS createdby,
    p.timestamp                     AS timestamp
  FROM dbo.PKGS AS p
  INNER JOIN dbo.SUPER_PKGS AS sp ON sp.PKG_ID = p.PKG_ID AND sp.PARENT_PKG_ID IS null
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = p.object_id



GO
GRANT SELECT ON [labkey_etl].[v_package] TO z_labkey

GO

