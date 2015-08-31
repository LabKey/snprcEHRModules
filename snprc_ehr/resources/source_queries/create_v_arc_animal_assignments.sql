USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter VIEW [labkey_etl].[v_arc_animal_assignments] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 8/14/2015
-- Description:	Selects the arc_animal_assignments for the LabKey dataset
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================

SELECT aaa.id, 
	aaa.start_date AS date,
	aaa.end_date AS enddate,
	aaa.arc_num_seq, 
	aaa.arc_num_genus,
	aaa.working_iacuc AS protocol,
	aaa.status AS assignment_status,
	aaa.object_id as objectid,
	aaa.user_name,
	aaa.entry_date_tm,
	(SELECT MAX(v) FROM (VALUES  (ca.timestamp), (aaa.timestamp )) AS VALUE (v) ) AS timestamp
	
 FROM dbo.arc_animal_assignments AS aaa
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aaa.id
INNER JOIN Labkey_etl.v_charge_account ca ON ca.protocol = aaa.working_iacuc
GO

GRANT SELECT ON labkey_etl.v_arc_animal_assignments TO z_labkey
GO


