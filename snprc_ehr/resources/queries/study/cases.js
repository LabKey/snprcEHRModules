require("ehr/triggers").initScript(this);

var console = require("console");
var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

// add caseId if it doesn't exist
function onInsert(helper, scriptErrors, row) {
    if (row.caseid === undefined) {
        row.caseid = snprcTriggerHelper.getNextCaseId();
    }
};