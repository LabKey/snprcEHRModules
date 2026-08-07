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
CREATE VIEW [labkey_etl].[v_delete_snd_attributeData] AS
-- ==========================================================================================
-- Author:		Binal Patel
-- Create date: 3/23/2018
-- Description:	Selects records to delete from exp.ObjectProperty
-- Note:
--
-- Changes:
-- Jay Allen - Only propagate a delete if the kew no longer exists in the source. EventDataAndName
--              is not unique when CAMP holds duplicate attribute rows, so cleaning up duplicate
--              caused ETL to delete the legitimate value from exp.ObjectProperty
--
-- ==========================================================================================

SELECT
  CONCAT (a.proc_id,'-',a.attrib_key) as EventDataAndName,
  a.audit_date_tm
FROM audit.audit_coded_proc_attribs AS a
WHERE a.audit_action = 'D'
    AND NOT EXISTS (
        SELECT 1
        FROM dbo.CODED_PROC_ATTRIBS cpa
        WHERE cpa.PROC_ID = a.PROC_ID
        AND cpa.ATTRIB_KEY = a.ATTRIB_KEY
    )
GO

GRANT SELECT on labkey_etl.v_delete_snd_AttributeData to z_labkey
GRANT SELECT ON audit.audit_coded_proc_attribs TO z_labkey
GO