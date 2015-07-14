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
/* View: V_ANIMAL_PROCEDURES                                    */
/*==============================================================*/
alter VIEW [labkey_etl].[V_ANIMAL_PROCEDURES] as
-- ====================================================================================================================
-- Object: v_animal_procedures
-- Author:		Terry Hawkins
-- Create date: 7/6/2015
--
-- ==========================================================================================


SELECT  ap.animal_event_id AS visitRowId,
        ap.animal_id AS id ,
        ap.event_date_tm AS date ,
        ap.ParticipantSequenceNum ,
        ap.charge_id AS project ,
        ap.proc_narrative AS remark ,
        ap.objectid ,
        ap.user_name ,
        ap.entry_date_tm ,
        ap.ts AS ts
 from dbo.animal_procedures AS ap
---- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ap.animal_id

go

grant SELECT on labkey_etl.v_animal_procedures to z_labkey

go