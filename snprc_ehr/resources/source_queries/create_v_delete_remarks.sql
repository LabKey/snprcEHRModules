CREATE VIEW [labkey_etl].[v_delete_remarks] as
-- ====================================================================================================================
-- Object: v_delete_remarks
-- Author:		Terry Hawkins
-- Create date: 5/23/2016
--
-- ==========================================================================================
SELECT 
	ar.object_id,
	ar.audit_date_tm

FROM audit.audit_remarks AS ar
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ar.id
WHERE ar.audit_action = 'D' AND ar.object_id IS NOT NULL
 
go

GRANT SELECT on labkey_etl.v_delete_remarks to z_labkey
GRANT SELECT ON audit.audit_remarks TO z_labkey

go