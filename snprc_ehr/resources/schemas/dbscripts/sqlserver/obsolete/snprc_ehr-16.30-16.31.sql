/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
