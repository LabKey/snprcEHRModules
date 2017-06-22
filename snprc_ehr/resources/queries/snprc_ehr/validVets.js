/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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