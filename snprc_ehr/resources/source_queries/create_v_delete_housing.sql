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
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/*==============================================================*/
/* View: V_AUDIT_LOCATION                                               */
/*==============================================================*/
ALTER VIEW labkey_etl.v_delete_housing as
-- ====================================================================================================================
-- Object: v_audit_location
-- Author:		Terry Hawkins
-- Create date: 6/12/2015
-- Changes:
-- 12/20/2017 added audit.audit_cage_position records tjh
-- ==========================================================================================
SELECT 
	CAST(al.object_id AS VARCHAR(36)) AS object_id,
	al.audit_date_tm

FROM audit.audit_location AS al
-- select primates only from the TxBiomed colony
INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = al.id
WHERE al.audit_action = 'D' AND al.object_id IS NOT NULL

UNION
-- get records from cage_position
SELECT cp.object_id, 
	cp.audit_date_tm

FROM audit.audit_cage_position AS cp
WHERE cp.audit_action = 'D' AND cp.object_id IS NOT NULL

go

GRANT SELECT on labkey_etl.v_delete_housing to z_labkey;
GRANT SELECT ON audit.audit_location TO z_labkey;
GRANT SELECT ON audit.audit_cage_position TO z_labkey;
go