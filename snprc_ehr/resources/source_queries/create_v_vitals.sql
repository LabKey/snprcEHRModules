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

/****** Object:  View [dbo].[V_VITALS]    Script Date: 12/19/2014 11:09:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_VITALS                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_VITALS] AS
-- ==========================================================================================
-- Object: v_vitals
-- Author: Terry Hawkins
-- Create date: 11/17/2015
-- Description:	Select vitals data for Labkey ETL
-- Changes:
-- 11/15/2016  added modified, modifiedby, created, and createdby, parentid columns tjh
-- 11/29/2016  added project column. tjh
--
-- ==========================================================================================

SELECT
  ID,
  DATE_TM                     AS date,
  project,
  CAST(RR AS NUMERIC(4, 0))   AS respRate,
  CAST(HR AS NUMERIC(4, 0))   AS heartRate,
  CAST(TEMP AS NUMERIC(5, 2)) AS temp,
  parentid,
  objectid,
  modified,
  modifiedby,
  NULL                        AS created,
  NULL                        AS createdby,
  timestamp
FROM

    (

      SELECT
        AE.ANIMAL_ID                              AS ID,
        AE.EVENT_DATE_TM                          AS DATE_TM,
        ae.charge_id                              AS project,
        CASE WHEN ISNUMERIC(cpa.value) <> 1
          THEN NULL
        ELSE CAST(CPA.VALUE AS NUMERIC(6, 2)) END AS VALUE,
        CPA.ATTRIB_KEY,
        AE.OBJECT_ID                              AS parentid,
        cp.OBJECT_ID                              AS objectid,
        CP.entry_date_tm                          AS modified,
        dbo.f_map_username(CP.user_name)          AS modifiedby,
        tc.created                                AS created,
        tc.createdby                              AS createdby,
        CP.TIMESTAMP

      FROM CODED_PROCS CP
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = cp.object_id
        INNER JOIN DBO.BUDGET_ITEMS AS BI ON CP.BUDGET_ITEM_ID = BI.BUDGET_ITEM_ID
        INNER JOIN DBO.SUPER_PKGS AS SP ON BI.SUPER_PKG_ID = SP.SUPER_PKG_ID
        INNER JOIN ANIMAL_EVENTS AE ON CP.ANIMAL_EVENT_ID = AE.ANIMAL_EVENT_ID
        LEFT OUTER JOIN CODED_PROC_ATTRIBS AS CPA ON CP.PROC_ID = CPA.PROC_ID
        -- select primates only from the TxBiomed colony
        INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id
      WHERE SP.PKG_ID IN (SELECT pc.PKG_ID
                          FROM dbo.PKG_CATEGORY AS pc
                            INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
                          WHERE vct.DESCRIPTION = 'vitals')
    ) AS SRC

  PIVOT (MAX(SRC.VALUE) FOR SRC.ATTRIB_KEY IN (HR, RR, TEMP)) AS P

GO


GRANT SELECT ON labkey_etl.V_VITALS TO z_labkey
GRANT SELECT ON dbo.CODED_PROCS TO z_labkey
GRANT SELECT ON dbo.CODED_PROC_ATTRIBS TO z_labkey
GO


