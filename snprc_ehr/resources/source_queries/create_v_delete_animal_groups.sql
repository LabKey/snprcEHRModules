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
/* View: V_DELETE_ANIMAL_GROUPS                                 */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_ANIMAL_GROUPS] as
-- ====================================================================================================================
-- Object: v_delete_animal_groups
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
-- 
-- 3/1/2016 added valid_pedigrees. tjh
-- ==========================================================================================
SELECT 
	avc.object_id,
	avc.audit_date_tm

FROM audit.audit_valid_colonies AS avc
WHERE avc.AUDIT_ACTION = 'D' AND avc.OBJECT_ID IS NOT NULL

UNION

SELECT 
	avb.object_id,
	avb.audit_date_tm

FROM audit.audit_valid_breeding_grps AS avb
WHERE avb.AUDIT_ACTION = 'D' AND avb.OBJECT_ID IS NOT NULL


UNION

SELECT 
	vp.object_id,
	vp.audit_date_tm

FROM AUDIT.audit_valid_pedigrees AS vp
WHERE vp.audit_action = 'D' AND vp.OBJECT_ID IS null
GO

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_GROUPS to z_labkey
GRANT SELECT ON audit.audit_valid_breeding_grps TO z_labkey
GRANT SELECT ON audit.audit_valid_colonies TO z_labkey
GRANT SELECT ON audit.audit_valid_pedigrees TO z_labkey

go