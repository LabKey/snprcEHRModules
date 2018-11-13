/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

/****** Object:  View [labkey_etl].[V_DELETE_ANIMAL_EVENT_NARRATIVES]    Script Date: 11/5/2015 10:17:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_ANIMAL_EVENT_NARRATIVES                                     */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_ANIMAL_EVENT_NARRATIVES] AS
-- ====================================================================================================================
-- Author:		Terry Hawkins
-- Create date: 7/13/2015
--
-- 11/02/2015   Terry Hawkins   Renamed from v_delete_animal_procedures to v_delete_animal_event_narratives.
-- ==========================================================================================
SELECT 
	aae.object_id,
	aae.audit_date_tm

FROM audit.audit_animal_events AS aae
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aae.animal_id
WHERE aae.AUDIT_ACTION = 'D' AND aae.OBJECT_ID IS NOT NULL


GO


