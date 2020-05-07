CREATE VIEW [labkey_etl].[v_valid_default_IACUC] AS
-- ==========================================================================================
-- Author:		Scott R Rouse
-- Create date: 05/06/2020
-- Description:	Selects the valid vets
-- Note: create_v_valid_default_IACUC.sql
-- Changes:
--
--
-- ==========================================================================================

SELECT v.working_iacuc  as WorkingIacuc,
       v.arc_num_seq    as ArcNumSeq,
       v.arc_num_genus  as ArcNumGenus,
       v.mandatory      as Mandatory,
       v.default_iacuc  as DefaultIacuc,
       v.object_id      AS ObjectId,
       v.entry_date_tm                                         AS modified,
       dbo.f_map_username(v.user_name)                         AS modifiedby,
       COALESCE(tc.created, v.entry_date_tm)                   AS created,
       COALESCE(tc.createdby, dbo.f_map_username(v.user_name)) AS createdBy,
       v.timestamp
FROM dbo.valid_default_iacuc v
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = v.object_id;

    GO