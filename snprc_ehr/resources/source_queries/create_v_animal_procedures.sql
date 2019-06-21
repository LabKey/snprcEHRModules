/*
 * Copyright (c) 2015-2019 LabKey Corporation
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
ALTER VIEW [labkey_etl].[V_ANIMAL_PROCEDURES] AS
-- ==========================================================================================
-- Object: v_animal_procedures
-- Author:		Terry Hawkins
-- Create date: 11/2/2015
--
-- 12/23/2015 added procNarrative, viewOrder, and procType. tjh
-- 3/2/2016	Added budgetItemId, parentBudgetItemId, and biPath, also updated the method for 
--			populating viewOrder.  The added information will allow for the packages to be
--          reassembled into animalEvent narratives. tjh
-- 11/4/2016 renamed user_name and entry_date_tm (modifiedby, modified, createdby, created). tjh
-- 11/16/2018 Issue 218  Changed procType to a CASE statement to correctly identify behavior procedures
--           previously considered maintenance. srr
-- ==========================================================================================
SELECT
  aep.id                                  AS id,
  aep.event_date_tm                       AS date,
  aep.ae_animal_event_id                  AS encounterId,
  aep.cp_object_id                        AS objectid,
  aep.PKG_ID                              AS pkgId,
  dbo.f_decoded_narrative(aep.PROC_ID, 0) AS procNarrative,
  aep.BUDGET_ITEM_ID                      AS budgetItemId,
  aep.PARENT_BUDGET_ITEM_ID               AS parentBudgetItemId,
  fbi.bi_path                             AS biPath,
  ROW_NUMBER()
  OVER (PARTITION BY aep.ae_animal_event_id
    ORDER BY fbi.bi_path)                 AS viewOrder,
  CASE
    WHEN aep.CHARGE_ID BETWEEN 6000 AND 6999 THEN 'B'
    ELSE aep.BUDGET_TYPE
      END                      AS procType,
  aep.USDA_CATEGORY                       AS usdaCategory,
  aep.cp_entry_date_tm                    AS modified,
  dbo.f_map_username(aep.cp_user_name)    AS modifiedby,
  tc.created                              AS created,
  tc.createdby                            AS createdby,
  CAST(aep.cp_timestamp AS TIMESTAMP)     AS timestamp
FROM dbo.v_aep AS aep
  INNER JOIN dbo.f_get_bi_paths() AS fbi
    ON fbi.budget_item_id = aep.BUDGET_ITEM_ID AND fbi.revision_num = aep.REVISION_NUM
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = aep.cp_object_id
  ---- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aep.id

GO

GRANT SELECT ON labkey_etl.V_ANIMAL_PROCEDURES TO z_labkey

GO