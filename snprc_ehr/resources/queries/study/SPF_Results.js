/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");

function beforeInsert(row, errors) {
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}
