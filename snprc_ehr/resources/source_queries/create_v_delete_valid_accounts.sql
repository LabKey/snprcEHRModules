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

/****** Object:  View [labkey_etl].[V_DELETE_VALID_ACCOUNTS]    Script Date: 3/9/2016 10:29:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [labkey_etl].[V_DELETE_VALID_ACCOUNTS] AS
-- ====================================================================================================================
-- Object: v_delete_valid_accounts
-- Author:		Terry Hawkins
-- Create date: 3/4/2016
--
-- ==========================================================================================
SELECT
	ava.object_id,
	ava.audit_date_tm

FROM audit.audit_valid_accounts AS ava
WHERE ava.AUDIT_ACTION = 'D' AND ava.OBJECT_ID IS NOT NULL

GO
