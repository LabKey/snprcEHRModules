ALTER VIEW labkey_etl.v_exp_procedure_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the procedure_history data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT ph.id,
       ph.proc_date as date,
       CASE WHEN ph.proc_date_estimator = 'Y' THEN 'true'
            WHEN ph.proc_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isDateEstimate,
       vpt.description AS procedureType,
       ph.comment AS comment,
       ph.object_id AS objectid,
       ph.entry_date_tm AS modified,
       dbo.f_map_username(ph.user_name) AS modifiedby,
       COALESCE(tc.created, ph.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(ph.user_name)) AS createdby,
       ph.timestamp AS timestamp

FROM exposure.dbo.procedure_history AS ph
--INNER JOIN animal.dbo.current_data AS m ON m.id = p.id --AND m.arc_species_code = 'PT'
         LEFT OUTER JOIN exposure.dbo.valid_procedure_types as vpt on vpt.procedure_type_id = ph.procedure_type_id
         LEFT OUTER JOIN exposure.dbo.valid_institutions as vi on vi.institution_id = ph.responsible_institution_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ph.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ph.id

    GO

GRANT SELECT ON labkey_etl.v_exp_procedure_history TO z_labkey
    GO