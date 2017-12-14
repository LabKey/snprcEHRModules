USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [labkey_etl].[v_delete_valid_charge_by_species] AS
-- ====================================================================================================================
-- Object: v_delete_valid_charge_by_species
-- Author:		Terry Hawkins
-- Create date: 12/14/2017
--
-- ==========================================================================================
SELECT
  av.object_id,
  av.audit_date_tm

FROM audit.audit_valid_charge_by_species AS av
WHERE av.AUDIT_ACTION = 'D' AND av.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_valid_charge_by_species TO z_labkey
GRANT SELECT ON audit.audit_valid_charge_by_species TO z_labkey

GO