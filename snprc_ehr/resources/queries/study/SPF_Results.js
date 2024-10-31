var console = require("console");
var LABKEY = require("labkey");

function beforeInsert(row, errors) {
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    console.log("SPF_Results.js:  row.id = " + row.id + "row.objectid: " + row.objectid)
}