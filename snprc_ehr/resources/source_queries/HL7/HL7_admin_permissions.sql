-- HL7_Admin permissions required for HL7 Schema Engine import

USE labkey

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_IMPORT_LOG TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_MSH TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_NTE TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_OBR TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_OBX TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_ORC TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_PID TO HL7_Admin;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON labkey.snprc_ehr.HL7_PV1 TO HL7_Admin;
GRANT SELECT ON labkey.snprc_ehr.HL7_Demographics TO hl7_admin;
GRANT EXECUTE ON labkey.snprc_ehr.f_isNumeric TO HL7_Admin;
GRANT SELECT ON labkey.snprc_ehr.HL7_GroupNTE TO HL7_Admin;
GRANT EXECUTE ON labkey.snprc_ehr.f_format_hl7_date TO HL7_Admin;
GRANT SELECT ON labkey.core.Containers TO HL7_Admin;
GRANT SELECT ON labkey.core.Principals TO hl7_admin;
GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyDiagnosesStaging TO hl7_admin;
GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyCasesStaging TO hl7_admin;
GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_PathologyDiagnosesStaging TO hl7_admin;
GRANT INSERT, UPDATE, DELETE ON labkey.snprc_ehr.HL7_DeletePathologyCasesStaging  TO hl7_admin;

-- Table permissions
USE animal
go
GRANT EXEC ON LIS.p_load_demographics TO z_labkey;
GRANT VIEW DEFINITION ON LIS.p_load_demographics TO z_labkey;

GO

USE tac_hl7_staging
GO

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_MessageManifest TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_MSH_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_PID_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_Segment_NTE_A TO labkey;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON tac_hl7_staging.dbo.TAC_HL7Data TO labkey;

GO

USE Orchard_AP_staging
GO

GRANT EXEC ON p_load_ap_data TO hl7_admin;
go