//var console = require("console");
var LABKEY = require("labkey");

var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function beforeInsert(row,errors) {
    var dCode = snprcTriggerHelper.getNextDietCode();
    console.log("dCode is " + dCode);
    console.log("row is " + row);
    console.log("rowDietCodePre is " + row.DietCode);

    if (row.DietCode === undefined || row.DietCode == 'undefined') {
       row.DietCode = dCode;
      //  row.DietCode  = snprcTriggerHelper.getNextDietCode();
    }

    console.log("rowDietCodePost is " + row.DietCode);
    console.log("rowSnomedCodePre is " + row.SnomedCode);
    if (row.SnomedCode === undefined || row.SnomedCode == 'undefined') {
        // Used to generate a 7 character FauxMed code i.e. S-001234

        // changed fauzRight to use DietCode instead of dCode.
        // dCode would only work for TAC sourced new diet
        var fauxRight = "00000" + row.DietCode;
        row.SnomedCode = "S-" + fauxRight.slice(fauxRight.length-5,fauxRight.length);
    }
    console.log("rowSnomedCodePost is " + row.SnomedCode);
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();

}
