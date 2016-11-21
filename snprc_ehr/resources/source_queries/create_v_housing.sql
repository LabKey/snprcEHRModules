/*
 * Copyright (c) 2015 LabKey Corporation
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

/****** Object:  View [labkey_etl].[V_HOUSING]    Script Date: 12/31/2014 2:54:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[V_HOUSING] AS
-- ====================================================================================================================
-- Object: v_housing
-- Author:	Terry Hawkins
-- Create date: 1/2015
-- Changes:
-- 11/11/2016  added modified, modifiedby, created, and createdby columns tjh
-- ==========================================================================================

SELECT
  L.ID                                          AS id,
  L.MOVE_DATE_TM                                AS date,
  COALESCE(L.exit_date_tm, cd.disp_date_tm_max) AS enddate,
  CAST(L.location AS VARCHAR(10))               AS room,
  L.OBJECT_ID                                   AS objectid,
  L.entry_date_tm                               AS modified,
  dbo.f_map_username(L.user_name)               AS modifiedby,
  tc.created                                    AS created,
  tc.createdby                                  AS createdby,
  L.TIMESTAMP
FROM location AS L
  INNER JOIN dbo.current_data AS cd ON cd.id = L.id
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = L.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = l.id

GO

GRANT SELECT ON labkey_etl.v_housing TO z_labkey
GO
