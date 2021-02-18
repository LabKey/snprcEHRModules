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
/* View: V_TB                                                   */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_TB] AS
-- ==========================================================================================
-- OBJECT: V_TB
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 8/3/15
-- DESCRIPTION:	VIEW CONTAINS THE DATA EQUALIVENCE OF THE ORIGINAL TB TABLE for the LabKey ETL
-- CHANGES:
-- 11/14/2016  added modified, modifiedby, created, and createdby columns tjh
-- 1/27/2021   added eventId. tjh
-- ==========================================================================================

SELECT

  ID,
  EventId,
  TST_DATE  AS DATE,
  TB_SITE   AS SITE,
  TB_RESULT AS RESULT,
  PROC_ID,
  CHARGE_ID AS project,
  parentid,
  objectid,
  modified,
  modifiedby,
  created,
  createdby,
  TIMESTAMP

FROM

    (

      SELECT
        AE.ANIMAL_ID                     AS ID,
        AE.ANIMAL_EVENT_ID               AS EventId,
        AE.EVENT_DATE_TM                 AS TST_DATE,
        CPA.VALUE,
        CPA.ATTRIB_KEY,
        ca.charge_id,
        CP.PROC_ID,
        ae.object_id                     AS parentid,
        cp.OBJECT_ID                     AS objectid,
        CP.entry_date_tm                 AS modified,
        dbo.f_map_username(CP.user_name) AS modifiedby,
        tc.created                       AS created,
        tc.createdby                     AS createdby,
        CP.TIMESTAMP

      FROM CODED_PROCS CP
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = cp.object_id
        JOIN DBO.BUDGET_ITEMS AS BI ON CP.BUDGET_ITEM_ID = BI.BUDGET_ITEM_ID
        JOIN DBO.SUPER_PKGS AS SP ON BI.SUPER_PKG_ID = SP.SUPER_PKG_ID
        JOIN ANIMAL_EVENTS AE ON CP.ANIMAL_EVENT_ID = AE.ANIMAL_EVENT_ID
        LEFT OUTER JOIN CODED_PROC_ATTRIBS AS CPA ON CP.PROC_ID = CPA.PROC_ID
        LEFT OUTER JOIN CHARGE_ACCOUNT AS CA ON AE.CHARGE_ID = CA.CHARGE_ID AND CA.STOP_DATE IS NULL
      WHERE SP.PKG_ID = 8
      -- TODO: TB needs to be added to valid_code_table
      --  WHERE SP.PKG_ID IN (SELECT pc.PKG_ID
      -- 										 FROM dbo.PKG_CATEGORY AS pc
      --  INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
      -- 																							WHERE vct.DESCRIPTION = 'TB')
    ) AS SRC

  PIVOT (MAX(SRC.VALUE) FOR SRC.ATTRIB_KEY IN (TB_SITE, TB_RESULT)) AS P

GO


GRANT SELECT ON labkey_etl.v_tb TO z_labkey
GO
