var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);


function beforeInsert(row, errors) {
    row.objectId = row.objectId || LABKEY.Utils.generateUUID().toUpperCase();

}