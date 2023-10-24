--
-- Description: This view is a wrapper for the table-valued function fGetAllSuperPkgs
--
CREATE VIEW [labkey_etl].[v_sndGetAllSuperPkgs] AS
(
    SELECT * FROM labkey_etl.fGetAllSuperPkgs()
);
GO

GRANT SELECT ON Labkey_etl.v_sndGetAllSuperPkgs TO z_labkey
GO