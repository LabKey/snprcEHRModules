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
/* View: V_BLOOD                                                */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_BLOOD] AS
-- ==========================================================================================
-- OBJECT: V_BLOOD
-- AUTHOR: TERRY HAWKINS
-- CREATE DATE: 8/3/2015
-- DESCRIPTION:	View provides the blood draw data for LabKey
-- CHANGES:
--
-- ==========================================================================================

SELECT 
	ID,
	BLEED_DATE_TM AS date, 
	ADMIT_CHARGE_ID,
	project,
	WORKING_IACUC,
	CAST(BLOOD_VOLUME AS NUMERIC(7,3)) AS quantity,
	REASON AS REASON,
	objectid,
	USER_NAME,
	ENTRY_DATE_TM,
	TIMESTAMP
FROM 

( 

 SELECT 
	AE.ANIMAL_ID AS ID,
	AE.EVENT_DATE_TM AS BLEED_DATE_TM,
	CASE WHEN AE.ADMIT_ID IS NULL OR AE.ADMIT_ID = 0
		THEN CASE WHEN AE.CHARGE_ID = 0 OR AE.CHARGE_ID IS NULL THEN '*' ELSE CAST(AE.CHARGE_ID AS VARCHAR) END
		ELSE CAST(AE.ADMIT_ID AS VARCHAR) END AS ADMIT_CHARGE_ID,
	ca.charge_id AS project,
	CASE WHEN AE.CHARGE_ID IS NULL OR AE.CHARGE_ID = 0 THEN '*' ELSE  CAST(ISNULL(CA.WORKING_IACUC,'*') AS VARCHAR) END AS WORKING_IACUC,
	CAST(cp.OBJECT_ID AS VARCHAR(36)) AS objectid,	
	CP.PROC_ID,
	CPA.VALUE  AS VALUE,
	CPA.ATTRIB_KEY,
	CPA.USER_NAME,
	CP.ENTRY_DATE_TM,
	CP.TIMESTAMP
	
 FROM CODED_PROCS CP
 JOIN DBO.BUDGET_ITEMS AS BI ON CP.BUDGET_ITEM_ID = BI.BUDGET_ITEM_ID
 JOIN DBO.SUPER_PKGS AS SP ON BI.SUPER_PKG_ID = SP.SUPER_PKG_ID
 JOIN ANIMAL_EVENTS AE ON CP.ANIMAL_EVENT_ID = AE.ANIMAL_EVENT_ID 
 JOIN CODED_PROC_ATTRIBS AS CPA ON CP.PROC_ID = CPA.PROC_ID
 LEFT OUTER JOIN CHARGE_ACCOUNT AS CA ON AE.CHARGE_ID = CA.CHARGE_ID AND CA.STOP_DATE IS NULL

 WHERE SP.PKG_ID = 7
 ) AS SRC

PIVOT (MAX(SRC.VALUE) FOR SRC.ATTRIB_KEY IN (BLOOD_VOLUME, REASON)) AS P
GO


GRANT SELECT ON Labkey_etl.V_BLOOD TO z_labkey
GO