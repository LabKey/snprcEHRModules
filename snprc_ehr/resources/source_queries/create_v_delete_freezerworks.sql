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
USE [animal]
GO

/****** Object:  View [labkey_etl].[V_FREEZERWORKS]    Script Date: 6/29/2015 11:31:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_FREEZERWORKS                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_FREEZERWORKS]
AS
    -- ====================================================================================================================
-- Object: V_DELETE_FREEZERWORKS
-- Author:	Scott Rouse
-- Create date: 06/26/2015
-- NOTE: currently returns 0 rows (where clause 1=0)
-- ==========================================================================================

SELECT  sa.object_id,
		sa.entry_date_tm,
		sa.sample_deleted, 
        sa.aliq_deleted 
FROM    [freezerworks].[SAMPLE_ALIQ] AS sa
WHERE sa.aliq_deleted = 1 and 1=0
  
GO

GRANT SELECT ON labkey_etl.v_delete_freezerworks TO z_labkey
GRANT SELECT ON freezerworks.SAMPLE_ALIQ TO z_labkey

GO



