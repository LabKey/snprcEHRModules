/*==============================================================*/
/* View: V_ANIMAL_PROCEDURES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_PROCEDURES] as
-- ==========================================================================================
-- Object: v_animal_procedures
-- Author:		Terry Hawkins
-- Create date: 11/2/2015
--
-- ==========================================================================================


SELECT  aep.id AS id,
        aep.event_date_tm AS date ,
        aep.ae_object_id AS encounterId,
        aep.cp_object_id AS procedureId,
		    aep.PKG_ID AS pkgId,
        aep.cp_user_name AS username,
        aep.cp_entry_date_tm AS entry_date_tm,
        CAST(aep.cp_timestamp AS TIMESTAMP) AS timestamp
 from dbo.v_aep AS aep
---- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aep.id

go

grant SELECT on labkey_etl.V_ANIMAL_PROCEDURES to z_labkey

go