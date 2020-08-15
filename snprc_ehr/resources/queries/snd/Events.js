
require("ehr/triggers").initScript(this);

function onInsert(helper, scriptErrors, row) {
    if (helper.isETL()) {
        row.QcState = EHR.Server.Security.getQCStateByLabel("Completed");
    }
};