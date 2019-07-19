/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var LABKEY = require("labkey");

function beforeInsert(row, errors) {
   row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}