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
-- ==========================================================================================

SELECT 
	
	ID,
	TST_DATE AS DATE, 
	TB_SITE AS SITE,
	TB_RESULT AS RESULT,
	PROC_ID,
	CHARGE_ID AS project,
	USER_NAME,
	ENTRY_DATE_TM,
	TIMESTAMP
	 
FROM 

( 

 SELECT 
	AE.ANIMAL_ID AS ID,
	AE.EVENT_DATE_TM AS TST_DATE,
	CPA.VALUE,
	CPA.ATTRIB_KEY,
	ca.charge_id,
	CP.PROC_ID,
	CP.USER_NAME,
	CP.ENTRY_DATE_TM,
	CP.TIMESTAMP
	
 FROM CODED_PROCS CP
 JOIN DBO.BUDGET_ITEMS AS BI ON CP.BUDGET_ITEM_ID = BI.BUDGET_ITEM_ID
 JOIN DBO.SUPER_PKGS AS SP ON BI.SUPER_PKG_ID = SP.SUPER_PKG_ID
 JOIN ANIMAL_EVENTS AE ON CP.ANIMAL_EVENT_ID = AE.ANIMAL_EVENT_ID 
 LEFT OUTER JOIN CODED_PROC_ATTRIBS AS CPA ON CP.PROC_ID = CPA.PROC_ID
 LEFT OUTER JOIN CHARGE_ACCOUNT AS CA ON AE.CHARGE_ID = CA.CHARGE_ID AND CA.STOP_DATE IS NULL
 WHERE SP.PKG_ID = 8 
 ) AS SRC

PIVOT (MAX(SRC.VALUE) FOR SRC.ATTRIB_KEY IN (TB_SITE, TB_RESULT)) AS P

GO


GRANT SELECT ON labkey_etl.v_tb TO z_labkey
go