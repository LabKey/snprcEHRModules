ALTER TABLE snprc_ehr.species ADD primate VARCHAR(1);

ALTER TABLE snprc_ehr.validAccounts DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.validAccounts DROP COLUMN userName;

ALTER TABLE snprc_ehr.labwork_services DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.labwork_services DROP COLUMN userName;

ALTER TABLE snprc_ehr.lab_tests DROP COLUMN entryDateTm;
ALTER TABLE snprc_ehr.lab_tests DROP COLUMN userName;