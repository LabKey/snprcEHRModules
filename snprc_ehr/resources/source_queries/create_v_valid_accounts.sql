/*
 * Copyright (c) 2016 LabKey Corporation
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

ALTER VIEW [labkey_etl].[V_VALID_ACCOUNTS] AS
-- ====================================================================================================================
-- Object: v_valid_acocunts
-- Author:		Terry Hawkins
-- Create date: 3/3/2016
-- ==========================================================================================

SELECT va.account,
	   va.status as accountStatus,
	   va.ori_date AS date,
	   va.close_date AS enddate,
	   CASE WHEN va.description IS NULL THEN 'Description is missing' ELSE va.description END AS description,
	   CASE WHEN va.account_group IS NULL THEN 'Undefined' ELSE va.account_group END  AS accountGroup,
       va.object_id AS objectid,
	   va.user_name AS userName,
	   va.entry_date_tm AS entryDateTm,
       va.timestamp
	   FROM dbo.valid_accounts AS va

GO


grant SELECT on labkey_etl.V_VALID_ACCOUNTS to z_labkey

go