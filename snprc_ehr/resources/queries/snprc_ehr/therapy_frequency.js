require("ehr/triggers").initScript(this);

var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function onInsert(helper, scriptErrors, row) {

    // add RowId if it doesn't exist
    if (row.RowId === undefined) {
        let rowid = snprcTriggerHelper.getNextTherapyId("therapy_frequency");

        if (rowid === undefined || rowid < 1) {
            console.log("Error retrieving next RowId.");
            EHR.Server.Utils.addError(scriptErrors, "RowId", "Error retrieving next RowId.", "ERROR");
        }
        else
        {
            row.RowId = rowid;
        }
    }
    // add ObjectId if it doesn't exist
    row.ObjectId = row.ObjectId || LABKEY.Utils.generateUUID().toUpperCase();
};