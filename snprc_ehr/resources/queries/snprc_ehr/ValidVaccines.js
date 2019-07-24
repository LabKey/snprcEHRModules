
/*
srr 07.24.2019
 */
var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function beforeInsert(row, errors) {
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}