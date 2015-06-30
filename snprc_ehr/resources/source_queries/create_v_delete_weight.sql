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

/*==============================================================*/
/* View: V_DELETE_WEIGHT                                               */
/*==============================================================*/
CREATE VIEW [labkey_etl].[v_delete_weight] as
-- ====================================================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/29/2015
--
-- ==========================================================================================
SELECT 
	aw.object_id,
	aw.audit_date_tm

FROM audit.audit_weight AS aw
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aw.id
WHERE aw.audit_action = 'D' AND aw.object_id IS NOT NULL
 
go

GRANT SELECT on labkey_etl.v_delete_weight to z_labkey
GRANT SELECT ON audit.audit_weight TO z_labkey

go