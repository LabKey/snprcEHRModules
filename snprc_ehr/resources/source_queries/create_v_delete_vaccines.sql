/*
 * Copyright (c) 2019 LabKey Corporation
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
/* View: v_vaccine data                                             */
/*==============================================================*/
CREATE VIEW [labkey_etl].[v_delete_vaccine] as
-- ====================================================================================================================
-- Object: v_delete_vaccines
-- Author:		Scott Rouse
-- Create date: 02/14/2019
-- Note: parts stolen from delete_blood
--
--	Changes:
--	srr added permits to audit_vaccine
-- ==========================================================================================

SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM
FROM audit.audit_coded_procs cp
       INNER JOIN dbo.ANIMAL_EVENTS ae
                  ON cp.animal_event_id = ae.animal_event_id
       INNER JOIN dbo.budget_items bi
                  ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
       INNER JOIN dbo.SUPER_PKGS sp
                  ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
  -- select primates only from the TxBiomed colony
       INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d
                  ON d.id = ae.animal_id
WHERE SP.PKG_ID IN (SELECT pc.PKG_ID FROM dbo.PKG_CATEGORY AS pc
                                            INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
                    WHERE vct.DESCRIPTION = 'Vaccination' )

  AND cp.AUDIT_ACTION = 'D'

GO

GRANT SELECT on labkey_etl.v_delete_vaccine to z_labkey
GRANT SELECT ON audit.audit_vaccine TO z_labkey

