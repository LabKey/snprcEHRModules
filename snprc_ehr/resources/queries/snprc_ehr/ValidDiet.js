/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);
// Generates SNPRC "Snomedcode" for diet srr 03.21.2019
function beforeInsert(row,errors) {
    //console.log("Inside beforeInsert");
    var dCode = snprcTriggerHelper.getNextDietCode();

    if (row.DietCode === undefined || row.DietCode == 'undefined') {
       row.DietCode = dCode;
        // Refactored to generate FauxMed code if DietCode is generated srr 03.26.19
        // Used to generate a 7 character FauxMed code i.e. S-001234
        var fauxRight = "00000" + dCode;
        row.SnomedCode = "S-" + fauxRight.slice(fauxRight.length-5,fauxRight.length);
    }
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();

}
