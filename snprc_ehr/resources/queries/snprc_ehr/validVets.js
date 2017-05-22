/**
 * Created by lkacimi on 5/22/2017.
 */
var console = require("console");
var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function beforeInsert(row, errors) {
    row.vetId = snprcTriggerHelper.getNextVetCode();
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}