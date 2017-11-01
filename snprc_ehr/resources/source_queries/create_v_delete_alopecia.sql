/*
 * Copyright (c) 2017 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_delete_weight]    Script Date: 8/4/2015 2:54:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [labkey_etl].[v_delete_alopecia] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/21/2017
-- Description:
-- Changes:
--
--
-- ==========================================================================================


SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM

FROM audit.audit_coded_procs cp
INNER JOIN dbo.ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN audit.audit_CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.pkg_id in (SELECT pc.PKG_ID FROM dbo.PKG_CATEGORY AS pc
						        INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
						        WHERE vct.DESCRIPTION = 'alopecia' )
			AND cpa.ATTRIB_KEY like '%alopecia%'
      AND cp.AUDIT_ACTION = 'D' AND cp.OBJECT_ID IS NOT null

UNION

-- include rows that have had the animal event deleted
SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM

FROM audit.audit_coded_procs cp
INNER JOIN audit.audit_ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN audit.audit_CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.pkg_id in (SELECT pc.PKG_ID FROM dbo.PKG_CATEGORY AS pc
						        INNER JOIN dbo.VALID_CODE_TABLE AS vct ON pc.CATEGORY_CODE = vct.CODE
						        WHERE vct.DESCRIPTION = 'alopecia' )
			AND cpa.ATTRIB_KEY like '%alopecia%'
      AND cp.AUDIT_ACTION = 'D' AND cp.OBJECT_ID IS NOT null


GO


GRANT SELECT ON labkey_etl.v_delete_alopecia TO z_labkey
GRANT SELECT ON audit.AUDIT_CODED_PROCS TO z_labkey
GRANT SELECT ON audit.AUDIT_CODED_PROC_ATTRIBS TO z_labkey
go