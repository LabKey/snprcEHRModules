/*
 * Copyright (c) 2018-2019 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_snd_attributeData]    Script Date: 4/2/2018 7:17:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_snd_attributeData]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/23/2018
-- Description:	View provides the datasource for event data with attribute/values
-- Changes:
-- 4/12/2018 added permnissions and trimmed leading and trailing spaces from attrib_keys. tjh
-- 10/11/2018 removing rows that have attribute values that are '' or null. tjh
-- 05/13/19  Added a REPLACE to numeric/decimal CAST
--           Purpose is to handle numeric data with commas (',') ~line 59  srr
-- 03/23/2021 Recent changes to dataintegration require the Key column to have the underscore prefix. tjh
-- ==========================================================================================
SELECT TOP (99.999999999) PERCENT
  cp.ANIMAL_EVENT_ID               AS EventId,
  sp.PKG_ID                        AS PkgId,
  -- snd.EventData columns
  cp.PROC_ID                       AS EventDataId,
  sp.SUPER_PKG_ID                  AS SuperPkgId,
  pbi.SUPER_PKG_ID                 AS ParentSuperPkgId,
  cpa.value AS value,
  -- exp.ObjectProperty columns
  ltrim(rtrim(cpa.ATTRIB_KEY)) AS [_KEY],

  CASE WHEN (LOWER(pa.DATA_TYPE) = 'numeric' OR
    LOWER(pa.DATA_TYPE) = 'decimal')
    THEN CAST (REPLACE(cpa.value,',','') AS FLOAT ) ELSE NULL END AS FloatValue,

  CASE WHEN LOWER(pa.DATA_TYPE) = 'string'
    THEN cpa.value ELSE NULL END AS StringValue,

  CASE WHEN (LOWER(pa.DATA_TYPE)) = 'string' THEN 's' ELSE 'f' END AS TypeTag,

cp.OBJECT_ID AS objectId,
( SELECT MAX(v) FROM ( VALUES (cp.timestamp), (cpa.timestamp)) AS VALUE (v)) AS TIMESTAMP


FROM dbo.CODED_PROCS AS cp
INNER JOIN dbo.ANIMAL_EVENTS AS ae ON cp.ANIMAL_EVENT_ID = ae.ANIMAL_EVENT_ID
INNER JOIN dbo.CODED_PROC_ATTRIBS AS cpa ON cpa.PROC_ID = cp.PROC_ID
INNER JOIN dbo.BUDGET_ITEMS AS bi ON cp.BUDGET_ITEM_ID = bi.BUDGET_ITEM_ID
INNER JOIN dbo.BUDGET_ITEMS AS pbi ON pbi.BUDGET_ITEM_ID = bi.PARENT_BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS AS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
INNER JOIN dbo.PKGS AS p ON p.PKG_ID = sp.PKG_ID
INNER JOIN dbo.PKG_ATTRIBS AS pa ON pa.PKG_ID = p.PKG_ID AND pa.ATTRIB_KEY = cpa.ATTRIB_KEY


-- select primates only from the TxBiomed colony
INNER JOIN labkey_etl.V_DEMOGRAPHICS AS D ON D.id = ae.ANIMAL_ID
WHERE LTRIM(RTRIM(cpa.VALUE)) <> '' AND  cpa.VALUE IS NOT NULL

ORDER BY EventDataId

GO

GRANT SELECT ON Labkey_etl.v_snd_attributeData TO z_labkey
GO