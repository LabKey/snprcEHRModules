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
/* View: V_ATTRIBUTES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ATTRIBUTES] as
-- ====================================================================================================================
-- Object: v_attributes
-- Author:		Terry Hawkins
-- Create date: 12/30/2015
--
-- ==========================================================================================

SELECT a.id ,
	   a.entry_date_tm AS date,
	   --a.attribute AS flag,
	   fv.code AS flag,
	   a.comment AS remark,
	   a.object_id AS objectId,
       a.user_name ,
       a.timestamp  
	   FROM dbo.attributes AS a
	   INNER JOIN labkey_etl.flag_values AS fv ON a.attribute = fv.value
---- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.id


go

grant SELECT on labkey_etl.V_ATTRIBUTES to z_labkey

go