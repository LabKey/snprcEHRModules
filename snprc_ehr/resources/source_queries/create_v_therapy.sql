/*
 * Copyright (c) 2015-2017 LabKey Corporation
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
/* View: V_THERAPY                                              */
/*==============================================================*/


ALTER VIEW [labkey_etl].[V_THERAPY] AS
-- ====================================================================================================================
-- Object: v_therapy
-- Author:	Terry Hawkins
-- Create date: 8/20/2015
-- Changes:
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
-- 11/29/2016  added project column. tjh
-- ==========================================================================================

SELECT
  t.ID                            AS id,
  t.start_date                    AS date,
  t.stop_date                     AS enddate,
  'Therapy'                       AS category,
  t.drug                          AS code,
  t.dose                          AS amount,
  t.units                         AS amount_units,
  t.route                         AS ROUTE,
  vtf.tid                         AS frequency,
  t.dx                            AS reason,
  t.tid                           AS visitRowId,
  ae.CHARGE_ID                    AS project,
  t.OBJECT_ID                     AS objectid,
  t.entry_date_tm                 AS modified,
  dbo.f_map_username(t.user_name) AS modifiedby,
  tc.created                      AS created,
  tc.createdby                    AS createdby,
  t.TIMESTAMP
FROM dbo.therapy AS t
  INNER JOIN dbo.valid_therapy_frequencies AS vtf ON vtf.frequency = t.frequency
  INNER JOIN dbo.animal_events AS ae ON t.animal_event_id = ae.ANIMAL_EVENT_ID
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = t.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS v ON v.id = t.id

GO

GRANT SELECT ON labkey_etl.v_therapy TO z_labkey
GO
