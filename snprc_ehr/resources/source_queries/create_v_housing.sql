USE [animal]
GO

/****** Object:  View [labkey_etl].[V_HOUSING]    Script Date: 12/31/2014 2:54:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_HOUSING                                              */
/*==============================================================*/


ALTER VIEW [labkey_etl].[V_HOUSING] AS
-- ====================================================================================================================
-- Object: v_housing
-- Author:	Terry Hawkins
-- Create date: 1/2015
-- ==========================================================================================

SELECT L.ID AS id, 
	L.MOVE_DATE_TM AS date,
	CAST(L.location AS VARCHAR(10)) AS room,
	L.OBJECT_ID AS objectid,
	L.TIMESTAMP
FROM location AS L
JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = L.id
--WHERE L.move_date_tm > '1/1/2014 00:00'

GO


