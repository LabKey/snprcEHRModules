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


CREATE VIEW [labkey_etl].[V_DELETE_PREGNANCY_CONFIRMATION] as
-- ====================================================================================================================
-- Object: v_delete_pregnancy_confirmation
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
--
-- ==========================================================================================
SELECT 
	ae.object_id,
	ae.audit_date_tm

FROM audit.audit_edc AS ae
WHERE ae.AUDIT_ACTION = 'D' AND ae.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.[V_DELETE_PREGNANCY_CONFIRMATION] to z_labkey
GRANT SELECT ON audit.audit_edc TO z_labkey


go