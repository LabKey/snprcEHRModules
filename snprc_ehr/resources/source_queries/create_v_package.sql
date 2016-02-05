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



CREATE VIEW [labkey_etl].[v_package] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/23/2015
-- Description:	selects the pkgs data
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT p.PKG_ID AS id,
	LEFT(p.DESCRIPTION, 100) AS name,
	p.NARRATIVE AS descriptiong,
	p.user_name AS user_name,
	p.entry_date_tm AS entry_date_tm,
	p.object_id AS objectid,
	p.timestamp AS timestamp
FROM dbo.PKGS AS p


GO
grant SELECT on [labkey_etl].[v_package] to z_labkey

go

