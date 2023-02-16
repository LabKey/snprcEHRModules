-- Increase procedure name size in OBR table
ALTER TABLE snprc_ehr.HL7_OBR ALTER COLUMN PROCEDURE_NAME VARCHAR(200) NULL