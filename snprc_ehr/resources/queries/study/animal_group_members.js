/*
 * Copyright (c) 2011-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true
    });
}

// animal_group_member validation is being done in \snprc_ehr\src\org\labkey\snprc_ehr\services\AnimalsGroupAssignor.java - assign()

// function onUpsert(helper, scriptErrors, row, oldRow) {
//
//     console.log("beforeUpdate triggered on animal_groups table");
//     console.log ("row = " + row);
//
//     row['_recordId'] = 1;
//     console.log (row);
//     scriptErrors['Id'] = [];
//     scriptErrors['Id'].push({
//         message: 'Fake error.',
//         severity: 'ERROR'
//     });
//     console.log(scriptErrors);
// }

