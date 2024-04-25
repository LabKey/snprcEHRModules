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
USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW labkey_etl.v_labwork_types AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/28/2017
-- Description:	selects data for the snprc_ehr.labwork_types table
-- Changes:
-- ==========================================================================================
SELECT
  lt.RowId,
  lt.ServiceType,
  lt.object_id                     AS objectid,
  lt.entry_date_tm                 AS Modified,
  dbo.f_map_username(lt.user_name) AS Modifiedby,
  tc.created                       AS Created,
  tc.createdBy                     AS Createdby,
  lt.timestamp
FROM dbo.CLINICAL_PATH_LABWORK_TYPES AS lt
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = lt.object_id
GO

GRANT SELECT ON labkey_etl.v_labwork_types TO z_labkey

GO
