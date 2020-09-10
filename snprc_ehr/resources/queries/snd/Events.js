var LABKEY = require("labkey");
require("ehr/triggers").initScript(this);

function onInsert(helper, scriptErrors, row) {
    if (helper.isETL()) {
        row.QcState = EHR.Server.Security.getQCStateByLabel("Completed");
    }
    // add objectid if it is missing
    row.ObjectId = row.ObjectId || LABKEY.Utils.generateUUID().toUpperCase();
};

