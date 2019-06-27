/*
 * Copyright (c) 2019 LabKey Corporation
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
/**************************************

srr
****************************************/
USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_location_temperature]    ******/
SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO




ALTER VIEW [labkey_etl].[v_delete_location_temperature] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/13/2019
-- Description:	Selects location_temperature for LabKey dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT al.object_id,
       al.audit_date_tm
FROM audit.audit_location_temperature AS al
	WHERE al.audit_action = 'D' AND al.object_id IS NOT NULL

  GO


GRANT SELECT on labkey_etl.v_delete_location_temperature to z_labkey
GRANT SELECT ON audit.audit_location_temperature TO z_labkey
