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
-- 2/20/2017 re-writen to query data directly from audit_animal_groups table. tjh
-- ==========================================================================================
SELECT 
	ag.object_id,
	ag.audit_date_tm

FROM audit.audit_animal_groups AS ag
WHERE ag.AUDIT_ACTION = 'D' AND ag.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_GROUPS to z_labkey
GRANT SELECT ON audit.audit_animal_groups TO z_labkey

go