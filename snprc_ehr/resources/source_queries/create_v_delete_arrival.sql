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

/*==============================================================*/
/* View: V_DELETE_ARRIVAL                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_ARRIVAL] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2015
-- Description:	Selects the ETL records for LabKey study.arrival dataset which need to be deleted
-- Changes:
-- 3/10/2021 Removed the join on the v_demographics view - if animal is removed from the colony
--      before the arrivals ETL runs, then the arrivals deletion will be missed
-- 7/2/2021 added join to improved demographics source which includes animals removed from colony. tjh
--
-- ==========================================================================================

SELECT
	ad.object_id,
	ad.audit_date_tm
FROM audit.audit_acq_disp AS ad
INNER JOIN Labkey_etl.v_demographics_for_delete AS d ON d.id = ad.id

WHERE ad.audit_action = 'D' AND ad.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_arrival TO z_labkey
GRANT SELECT ON audit.audit_acq_disp TO z_labkey

GO

