var console = require("console");
var LABKEY = require("labkey");
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);
console.log("Started");
function beforeInsert(row,errors) {
    //console.log("Inside beforeInsert");
    var dCode = snprcTriggerHelper.getNextDietCode();
    console.log("dCode is " + dCode);
    console.log("row is " + row);
    if (row.DietCode === undefined || row.DietCode == 'undefined') {
       row.DietCode = dCode;
      //  row.DietCode  = snprcTriggerHelper.getNextDietCode();
    }
    if (row.SnomedCode === undefined || row.SnomedCode == 'undefined') {
        // Used to generate a 7 character FauxMed code i.e. S-001234
        var fauxRight = "00000" + dCode;
        row.SnomedCode = "S-" + fauxRight.slice(fauxRight.length-5,fauxRight.length);
    }
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();

    console.log("objectid: " + row.objectid);
    console.log("DietCode: " + row.DietCode);
    console.log("snom: " + row.SnomedCode);
    console.log("Ending row is " + row);
}
