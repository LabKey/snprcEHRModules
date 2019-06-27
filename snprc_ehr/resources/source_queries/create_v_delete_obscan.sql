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

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_delete_obscan                                               */
/*==============================================================*/
create VIEW [labkey_etl].[v_delete_obscan] as
-- ====================================================================================================================
-- Object: v_delete_obscan
-- Author:		Scott Rouse
-- Create date: 02/15/2019
--
-- ==========================================================================================
SELECT
  ao.object_id,
  ao.audit_date_tm
FROM audit.audit_obscan AS ao
       -- select primates only from the TxBiomed colony
       INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ao.id
WHERE ao.audit_action = 'D' AND ao.object_id IS NOT NULL

 go

GRANT SELECT on labkey_etl.v_delete_obscan to z_labkey
GRANT SELECT ON audit.audit_obscan TO z_labkey

go