var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);


function beforeInsert(row, errors) {
    if (row.institution_id === undefined || row.institution_id == 'undefined') {
        row.institution_id = snprcTriggerHelper.getNextInstitutionCode();
    }

    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}