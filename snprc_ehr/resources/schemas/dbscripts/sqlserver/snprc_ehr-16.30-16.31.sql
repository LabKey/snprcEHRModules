ALTER TABLE snprc_ehr.labwork_services ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.labwork_services ADD diModified DATETIME;
ALTER TABLE snprc_ehr.labwork_services ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.labwork_services ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.lab_tests ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.lab_tests ADD diModified DATETIME;
ALTER TABLE snprc_ehr.lab_tests ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.lab_tests ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package_category ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package_category ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package_category ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package_category ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.package_category_junction ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.package_category_junction ADD diModified DATETIME;
ALTER TABLE snprc_ehr.package_category_junction ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.package_category_junction ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validAccounts ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validAccounts ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validAccounts ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validAccounts ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validInstitutions ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validInstitutions ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validInstitutions ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validInstitutions ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.species ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.species ADD diModified DATETIME;
ALTER TABLE snprc_ehr.species ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.species ADD diModifiedBy USERID;

ALTER TABLE snprc_ehr.validVets ADD diCreated DATETIME;
ALTER TABLE snprc_ehr.validVets ADD diModified DATETIME;
ALTER TABLE snprc_ehr.validVets ADD diCreatedBy USERID;
ALTER TABLE snprc_ehr.validVets ADD diModifiedBy USERID;
