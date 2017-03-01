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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_ANIMAL_EVENT_NARRATIVES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_EVENT_NARRATIVES] AS
-- ====================================================================================================================
-- Object: v_animal_event_narratives
-- Author:		Terry Hawkins
-- Create date: 7/6/2015
--
-- 11/02/2015   Terry Hawkins   Renamed from v_animal_procedures to v_animal_event_narratives.
-- 12/29/2015	Terry Hawkins	renamed visitRowId column to encounterId
-- 11/3/2016  added modified, modifiedby, created, createdby columns tjh
-- 2/28/2017	added encounter_type column. tjh
-- ==========================================================================================


SELECT
  ap.animal_event_id               AS encounterId,
  ap.animal_id                     AS id,
  ap.event_date_tm                 AS date,
  ap.ParticipantSequenceNum,
  ap.charge_id                     AS project,
  ap.proc_narrative                AS remark,
  'procedure'                      AS encounter_type,
  ap.objectid,
  ap.entry_date_tm                 AS modified,
  dbo.f_map_username(ap.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  CAST(ap.ts AS TIMESTAMP)         AS timestamp
FROM dbo.animal_event_narratives AS ap
  ---- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ap.animal_id
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ap.objectid


GO

GRANT SELECT ON labkey_etl.V_ANIMAL_EVENT_NARRATIVES TO z_labkey

GO