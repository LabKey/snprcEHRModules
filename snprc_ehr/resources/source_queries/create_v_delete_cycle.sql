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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_CYCLE                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_CYCLE] AS
-- ====================================================================================================================
-- Author:	Terry Hawkins
-- Create date: 8/19/2015
--
-- ==========================================================================================

SELECT 
	CAST(object_id AS VARCHAR(128)) + '/' + category AS object_id,
	audit_date_tm
 
 FROM  ( SELECT 
          CAST(male_status AS VARCHAR(8)) AS male_status,
          CAST(male_id AS VARCHAR(8)) AS male_id ,
          CAST(tumescence_index AS VARCHAR(8)) AS tumescence_index,
          CAST(vaginal_bleeding AS VARCHAR(8)) AS vaginal_bleeding,
          CAST(purple_color AS VARCHAR(8)) AS purple_color,
          CAST(carrying_infant AS VARCHAR(8)) AS carrying_infant,
		  CAST(cycle_location AS VARCHAR(8)) AS cycle_location,
		  CAST(observer_emp_num AS VARCHAR(8)) AS observer_emp_num,
		  object_id,
		  audit_date_tm
        FROM AUDIT.audit_cycle AS c
		-- select primates only from the TxBiomed colony
		INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id
		WHERE c.audit_action = 'D' AND c.object_id IS NOT NULL
) AS p

		UNPIVOT (observation FOR category IN 
		 ( male_status, tumescence_index, vaginal_bleeding,purple_color , carrying_infant, male_id, cycle_location, observer_emp_num)) AS u


go

GRANT SELECT ON labkey_etl.V_DELETE_CYCLE TO z_labkey
GRANT SELECT ON audit.AUDIT_CYCLE TO z_labkey
go

go

