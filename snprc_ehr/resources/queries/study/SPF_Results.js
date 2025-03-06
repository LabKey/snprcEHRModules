var console = require("console");
var LABKEY = require("labkey");

function beforeInsert(row, errors) {
    console.log("beforeInsert");
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    console.log("Insert spf_results.js:  row.Sample_number = " + row.Sample_number + " -- row.objectid = " + row.objectid)
}

function beforeUpdate(row, errors) {
    console.log("beforeUpdate");
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    console.log("Update spf_results.js:  row.Sample_number = " + row.Sample_number + " -- row.objectid = " + row.objectid)
}