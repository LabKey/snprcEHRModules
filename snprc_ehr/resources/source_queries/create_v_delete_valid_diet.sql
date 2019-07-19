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
USE [animal]
GO

CREATE VIEW [labkey_etl].[v_delete_valid_diet] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 03/05/2019
-- Description:	Selects the valid_diet for LabKey snprc_ehr.valid_diet dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avd.object_id,
       avd.audit_date_tm


FROM audit.audit_valid_diet AS avd

WHERE avd.audit_action = 'D' AND avd.object_id IS NOT NULL



  GO


GRANT SELECT on labkey_etl.v_delete_valid_diet to z_labkey
GRANT SELECT ON audit.audit_valid_diet TO z_labkey

  go