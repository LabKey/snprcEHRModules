USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--CREATE VIEW [labkey_etl].[v_clinical_admissions] AS
---- ==========================================================================================
---- Author:		Terry Hawkins
---- Create date: 8/14/2015
---- Description:	Selects the arc_animal_assignments for the LabKey dataset
---- Note: 
----		
---- Changes:
----
---- ==========================================================================================

INSERT INTO dbo.arc_animal_assignments
        ( id ,
          arc_num_seq ,
          arc_num_genus ,
          start_date ,
          end_date ,
          status ,
          comments ,
          object_id ,
          user_name ,
          entry_date_tm ,
          timestamp
        )
VALUES  ( '' , -- id - varchar(6)
          0 , -- arc_num_seq - smallint
          '' , -- arc_num_genus - char(2)
          GETDATE() , -- start_date - datetime
          GETDATE() , -- end_date - datetime
          '' , -- status - char(1)
          '' , -- comments - varchar(50)
          NULL , -- object_id - uniqueidentifier
          '' , -- user_name - varchar(128)
          GETDATE() , -- entry_date_tm - datetime
          NULL  -- timestamp - timestamp
        )

SELECT c.id AS id,
	   c.admit_date_tm AS date, 
	   LTRIM(RTRIM(c.id)) + '/' + CAST(c.admit_id AS VARCHAR(128)) AS ParticipantSequenceNum,
	   c.release_date_tm AS enddate,
	   c.pdx AS problem,
	   c.admit_complaint AS remark,
	   c.admit_id AS caseid,
	   c.admit_code AS category,
	   c.charge_id AS project,
	   c.vet_name AS vetreviewer,  -- this should be assigned vet; however, we are missing the ehr_lookup.veterinarians table
	   c.user_name AS user_name,
	   c.entry_date_tm AS entry_date_tm,
	   c.object_id AS objectid,
	   c.timestamp AS timestamp



FROM dbo.clinic AS c
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id


GO


