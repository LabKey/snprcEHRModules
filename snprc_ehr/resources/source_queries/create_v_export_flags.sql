create VIEW labkey_export.v_export_flags as
SELECT [id]
      ,[attribute]
      ,[comment]
      ,[tid]
      ,[object_id]
      ,[user_name]
      ,[entry_date_tm]
      ,[timestamp]
  FROM [animal].[dbo].[attributes]

  go

  GRANT SELECT, INSERT, UPDATE, DELETE ON labkey_export.v_export_flags TO z_labkey
  GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.attributes TO z_labkey
  go