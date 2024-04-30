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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [labkey_etl].[V_DELETE_LABWORK_PANELS] AS
-- ==========================================================================================
-- Object: v_delete_labwork_panels
-- Author:		Terry Hawkins
-- Create date: 5/6/2016
--
-- 6/28/2017 renamed from v_lab_tests
-- ==========================================================================================
SELECT
  lp.object_id,
  lp.audit_date_tm

FROM audit.AUDIT_CLINICAL_PATH_LABWORK_PANELS AS lp
WHERE lp.AUDIT_ACTION = 'D' AND lp.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON labkey_etl.V_DELETE_LABWORK_PANELS TO z_labkey
GRANT SELECT ON AUDIT.AUDIT_CLINICAL_PATH_LABWORK_PANELS TO z_labkey
GO