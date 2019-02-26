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

/*==============================================================*/
/* View: V_ATTRIBUTES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ATTRIBUTES] AS
-- ====================================================================================================================
-- Object: v_attributes
-- Author:		Terry Hawkins
-- Create date: 12/30/2015
-- Changes:
-- 11/10/2016  added modified, modifiedby, created, and createdby columns tjh
--
-- ==========================================================================================

SELECT
  a.id,
  a.entry_date_tm                 AS date,
  fv.code                         AS flag,
  a.comment                       AS remark,
  a.object_id                     AS objectId,
  a.entry_date_tm                 AS modified,
  dbo.f_map_username(a.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  a.timestamp
FROM dbo.attributes AS a
  INNER JOIN labkey_etl.v_flag_values AS fv ON a.attribute = fv.value
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = a.object_id
  ---- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.id


GO

GRANT SELECT ON labkey_etl.V_ATTRIBUTES TO z_labkey

GO