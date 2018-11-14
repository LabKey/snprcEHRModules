/*
 * Copyright (c) 2018 LabKey Corporation
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


CREATE VIEW [labkey_etl].[V_DELETE_VALID_LOCATIONS] AS
-- ===========================================================================================================
-- Object: v_delete_valid_locations
-- Author:		Scott Rouse
-- Create date: 3/14/2018
--  Using room because LK table does not have objectID
-- ===========================================================================================================
SELECT
  avl.location as [room],
  avl.audit_date_tm

FROM audit.audit_valid_locations AS avl
WHERE avl.AUDIT_ACTION = 'D'

GO

GRANT SELECT ON Labkey_etl.V_DELETE_VALID_LOCATIONS TO z_labkey
GRANT SELECT ON audit.audit_valid_locations TO z_labkey
