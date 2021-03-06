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
/* View: V_DELETE_WEIGHT                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_WEIGHT] AS
-- ====================================================================================================================
-- Author:	Terry Hawkins
-- Create date: 6/30/2015
-- 11/20/2015 refactored query to use pkg_category table to select pkg ids. tjh
-- ==========================================================================================

SELECT DISTINCT ISNULL(ae.ANIMAL_ID, aae.ANIMAL_ID) AS animal_id,
		ISNULL(ae.EVENT_DATE_TM, aae.EVENT_DATE_TM) AS event_date_tm,
		acp.OBJECT_ID,
       acp.AUDIT_DATE_TM

FROM audit.AUDIT_CODED_PROCS AS acp
LEFT OUTER JOIN dbo.animal_events AS ae ON ae.ANIMAL_EVENT_ID = acp.ANIMAL_EVENT_ID
LEFT OUTER JOIN audit.AUDIT_ANIMAL_EVENTS AS aae ON aae.ANIMAL_EVENT_ID = acp.ANIMAL_EVENT_ID
INNER JOIN dbo.BUDGET_ITEMS AS bi ON bi.BUDGET_ITEM_ID = acp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS AS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
WHERE SP.PKG_ID IN (SELECT pc.PKG_ID FROM dbo.PKG_CATEGORY AS pc
						INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
						WHERE vct.DESCRIPTION = 'weight' )
AND acp.AUDIT_ACTION = 'D' AND acp.OBJECT_ID IS NOT null

go
GRANT SELECT ON labkey_etl.V_DELETE_WEIGHT TO z_labkey
GRANT SELECT ON dbo.animal_events TO z_labkey
GRANT SELECT ON audit.AUDIT_CODED_PROCS TO z_labkey
GRANT SELECT ON audit.AUDIT_ANIMAL_EVENTS TO z_labkey
go


