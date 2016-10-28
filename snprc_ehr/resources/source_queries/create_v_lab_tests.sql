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

ALTER VIEW labkey_etl.v_lab_tests AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 5/6/2016
-- Description:	selects data for the snprc_ehr.lab_tests lookup table
-- Changes:
--
--
-- ==========================================================================================
SELECT til.test_type AS [type],
     til.test_id as [testid],
     til.test_name as [name],
     til.units as [units],
     0 as [alertOnAbnormal],
     0 as [alertOnAny],
     1 as [includeInPanel],
     til.sort_order as [sort_order],
 	   til.object_id AS [objectId],
	   til.ENTRY_DATE_TM AS [entryDateTm],
	   til.USER_NAME AS [userName]
FROM dbo.CLINICAL_PATH_TEST_ID_LOOKUP AS til
GO

GRANT SELECT ON labkey_etl.v_lab_tests TO z_labkey
  
GO