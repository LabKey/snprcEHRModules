/*
 * Copyright (c) 2015-2019 LabKey Corporation
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


alter VIEW [labkey_etl].[V_DELETE_ANIMAL_GROUP_MEMBERS] as
-- ====================================================================================================================
-- Object: v_delete_animal_group_members
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
-- 3/1/2016 Added pedigrees. tjh
-- 3/3/2016 Added account_group. tjh
-- 3/8/2016 Removed account_group. tjh
-- 2/20/2017 Added animal_group_members. tjh
-- 4/1/2019 Removed animal_group_members. tjh
-- ==========================================================================================
SELECT 
	ac.object_id,
	ac.audit_date_tm

FROM audit.audit_colony AS ac
WHERE ac.AUDIT_ACTION = 'D' AND ac.OBJECT_ID IS NOT NULL

UNION

SELECT 
	ab.object_id,
	ab.audit_date_tm

FROM audit.audit_breeding_grp AS ab
WHERE ab.AUDIT_ACTION = 'D' AND ab.OBJECT_ID IS NOT NULL

UNION

SELECT p.object_id,
		p.audit_date_tm

FROM audit.audit_pedigree AS p
WHERE p.AUDIT_ACTION = 'D' AND p.object_id IS NOT NULL

-- UNION
--
-- SELECT agm.object_id,
-- 			 agm.audit_date_tm
--
-- FROM audit.audit_animal_group_members AS agm
-- WHERE agm.AUDIT_ACTION = 'D' AND agm.object_id IS NOT NULL

GO 

GRANT SELECT on labkey_etl.V_DELETE_ANIMAL_GROUP_MEMBERS to z_labkey
GRANT SELECT ON audit.audit_breeding_grp TO z_labkey
GRANT SELECT ON audit.audit_colony TO z_labkey
GRANT SELECT ON audit.audit_pedigree TO z_labkey


go