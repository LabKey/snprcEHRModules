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
/* View: V_BLOOD                                                */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_BLOOD] AS
-- ==========================================================================================
-- OBJECT: V_BLOOD
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 8/3/2015
-- DESCRIPTION:	View provides the blood draw data for LabKey
-- Changes:
-- 11/10/2016  added modified, modifiedby, created, and createdby columns tjh
-- 1/27/2021   added eventId column and joined with demographics view tjh
--
-- ==========================================================================================

SELECT
  ID,
  EventId,
  BLEED_DATE_TM                       AS date,
  ADMIT_CHARGE_ID,
  project,
  WORKING_IACUC,
  CAST(BLOOD_VOLUME AS NUMERIC(7, 3)) AS quantity,
  REASON                              AS REMARK,
  objectid,
  modified,
  modifiedby,
  created,
  createdby,
  TIMESTAMP
FROM

    (

      SELECT
        AE.ANIMAL_ID                                            AS ID,
        AE.ANIMAL_EVENT_ID                                      AS EventId,
        AE.EVENT_DATE_TM                                        AS BLEED_DATE_TM,
        CASE WHEN AE.ADMIT_ID IS NULL OR AE.ADMIT_ID = 0
          THEN CASE WHEN AE.CHARGE_ID = 0 OR AE.CHARGE_ID IS NULL
            THEN '*'
               ELSE CAST(AE.CHARGE_ID AS VARCHAR) END
        ELSE CAST(AE.ADMIT_ID AS VARCHAR) END                   AS ADMIT_CHARGE_ID,
        ca.charge_id                                            AS project,
        CASE WHEN AE.CHARGE_ID IS NULL OR AE.CHARGE_ID = 0
          THEN '*'
        ELSE CAST(ISNULL(CA.WORKING_IACUC, '*') AS VARCHAR) END AS WORKING_IACUC,


        CP.PROC_ID,
        CPA.VALUE                                               AS VALUE,
        CPA.ATTRIB_KEY,
        cp.OBJECT_ID                                            AS objectid,
        CP.entry_date_tm                                        AS modified,
        dbo.f_map_username(CP.user_name)                        AS modifiedby,
        tc.created                                              AS created,
        tc.createdby                                            AS createdby,
        CP.TIMESTAMP

      FROM CODED_PROCS CP
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = cp.object_id
        INNER JOIN DBO.BUDGET_ITEMS AS BI ON CP.BUDGET_ITEM_ID = BI.BUDGET_ITEM_ID
        INNER JOIN DBO.SUPER_PKGS AS SP ON BI.SUPER_PKG_ID = SP.SUPER_PKG_ID
        INNER JOIN ANIMAL_EVENTS AE ON CP.ANIMAL_EVENT_ID = AE.ANIMAL_EVENT_ID
        INNER JOIN CODED_PROC_ATTRIBS AS CPA ON CP.PROC_ID = CPA.PROC_ID
        LEFT OUTER JOIN CHARGE_ACCOUNT AS CA ON AE.CHARGE_ID = CA.CHARGE_ID AND CA.STOP_DATE IS NULL
        -- select primates only from the TxBiomed colony
        INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = AE.ANIMAL_ID
      WHERE SP.PKG_ID IN (SELECT pc.PKG_ID
                          FROM dbo.PKG_CATEGORY AS pc
                            INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
                          WHERE vct.DESCRIPTION = 'Cumulative Blood')
    ) AS SRC

  PIVOT (MAX(SRC.VALUE) FOR SRC.ATTRIB_KEY IN (BLOOD_VOLUME, REASON)) AS P
GO


GRANT SELECT ON Labkey_etl.V_BLOOD TO z_labkey
GO
