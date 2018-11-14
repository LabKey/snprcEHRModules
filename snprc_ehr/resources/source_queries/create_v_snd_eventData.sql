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
ALTER VIEW [labkey_etl].[v_snd_eventData]
AS
    -- ==========================================================================================
    -- Author:		Terry Hawkins
    -- Create date: 2/23/2018
    -- Description:	View provides the datasource for event data with attribute/values
    -- Changes: 4/12/2018 Added permissions
    --
    -- ==========================================================================================

    SELECT
            cp.ANIMAL_EVENT_ID                AS EventId,
            sp.PKG_ID                         AS PkgId,
            cp.PROC_ID                        AS EventDataId,
            cp.PARENT_PROC_ID                 AS ParentEventDataId,
            sp.SUPER_PKG_ID                   AS SuperPkgId,
			      cp.timestamp					            AS timestamp

    FROM dbo.CODED_PROCS AS cp
	    INNER JOIN dbo.ANIMAL_EVENTS AS ae ON cp.ANIMAL_EVENT_ID = ae.ANIMAL_EVENT_ID
        INNER JOIN dbo.BUDGET_ITEMS AS bi ON cp.BUDGET_ITEM_ID = bi.BUDGET_ITEM_ID
		INNER JOIN dbo.BUDGET_ITEMS AS pbi ON pbi.BUDGET_ITEM_ID = bi.PARENT_BUDGET_ITEM_ID
        INNER JOIN dbo.SUPER_PKGS AS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
		INNER JOIN dbo.PKGS AS p ON p.PKG_ID = sp.PKG_ID

        -- get created and createdBy columns for coded_procs
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = cp.OBJECT_ID

        -- select primates only from the TxBiomed colony
        INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.ANIMAL_ID;

GO

GRANT SELECT ON Labkey_etl.v_snd_eventData TO z_labkey
GO