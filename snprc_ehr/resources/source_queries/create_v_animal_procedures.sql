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
/*==============================================================*/
/* View: V_ANIMAL_PROCEDURES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_PROCEDURES] as
-- ==========================================================================================
-- Object: v_animal_procedures
-- Author:		Terry Hawkins
-- Create date: 11/2/2015
--
-- 12/23/2015 added procNarrative, viewOrder, and procType. tjh
-- ==========================================================================================


SELECT  aep.id AS id,
        aep.event_date_tm AS date ,
        aep.ae_animal_event_id AS encounterId,
        aep.cp_object_id AS objectid,
		aep.PKG_ID AS pkgId,
		dbo.f_decoded_narrative(aep.PROC_ID, 0) AS procNarrative,
		aep.VIEW_ORDER AS viewOrder,
		aep.BUDGET_TYPE AS procType,
		aep.USDA_CATEGORY AS usdaCategory,
        aep.cp_user_name AS username,
        aep.cp_entry_date_tm AS entry_date_tm,
        CAST(aep.cp_timestamp AS TIMESTAMP) AS timestamp
 from dbo.v_aep AS aep
---- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aep.id

go

grant SELECT on labkey_etl.V_ANIMAL_PROCEDURES to z_labkey

go