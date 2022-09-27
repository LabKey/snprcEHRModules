var console = require("console");
var LABKEY = require("labkey");

function beforeInsert(row, errors) {
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    console.log("taqmanResults.js:  row.id = " + row.id + " -- row.objectid = " + row.objectid)
}