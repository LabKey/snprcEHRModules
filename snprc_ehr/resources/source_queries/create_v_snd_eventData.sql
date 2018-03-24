USE [animal]
GO

/****** Object:  View [labkey_etl].[v_snd_eventData]    Script Date: 3/23/2018 5:49:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [labkey_etl].[v_snd_eventData]
AS
    -- ==========================================================================================
    -- Author:		Terry Hawkins
    -- Create date: 2/23/2018
    -- Description:	View provides the datasource for event data with attribute/values
    -- Changes:
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