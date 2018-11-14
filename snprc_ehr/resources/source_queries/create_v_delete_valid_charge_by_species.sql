/*
 * Copyright (c) 2017-2018 LabKey Corporation
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


CREATE VIEW [labkey_etl].[v_delete_valid_charge_by_species] AS
-- ====================================================================================================================
-- Object: v_delete_valid_charge_by_species
-- Author:		Terry Hawkins
-- Create date: 12/14/2017
--
-- ==========================================================================================
SELECT
  av.object_id,
  av.audit_date_tm

FROM audit.audit_valid_charge_by_species AS av
WHERE av.AUDIT_ACTION = 'D' AND av.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_valid_charge_by_species TO z_labkey
GRANT SELECT ON audit.audit_valid_charge_by_species TO z_labkey

GO