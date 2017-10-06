SELECT
a.Comment as object_id,
a.Date as entry_date_tm
FROM auditLog.QueryExportAuditEvent AS a
WHERE a.SchemaName='snprc_ehr'
AND a.QueryName = 'animal_groups'