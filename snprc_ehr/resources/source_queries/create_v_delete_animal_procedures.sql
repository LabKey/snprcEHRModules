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

/****** Object:  View [labkey_etl].[V_DELETE_ANIMAL_PROCEDURES]    Script Date: 11/5/2015 10:09:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_ANIMAL_PROCEDURES                             */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_ANIMAL_PROCEDURES] AS
-- =========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/3/2015
--
-- ==========================================================================================
SELECT 
	acp.object_id,
	acp.audit_date_tm

FROM audit.AUDIT_CODED_PROCS AS acp
-- select primates only from the TxBiomed colony
WHERE acp.AUDIT_ACTION = 'D' AND acp.OBJECT_ID IS NOT NULL


GO


