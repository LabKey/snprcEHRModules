/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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