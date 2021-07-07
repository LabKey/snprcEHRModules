//var console = require("console");
var LABKEY = require("labkey");

var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function beforeInsert(row,errors) {
    // TAC generated diet only
    var dCode = snprcTriggerHelper.getNextDietCode();

    if (row.DietCode === undefined || row.DietCode == 'undefined') {
       row.DietCode = dCode;
      //  row.DietCode  = snprcTriggerHelper.getNextDietCode();
    }

    if (row.SnomedCode === undefined || row.SnomedCode == 'undefined') {
        // Used to generate a 7 character FauxMed code i.e. S-001234

        // changed fauzRight to use DietCode instead of dCode.
        // dCode would only work for TAC sourced new diet
        var fauxRight = "00000" + row.DietCode;
        row.SnomedCode = "S-" + fauxRight.slice(fauxRight.length-5,fauxRight.length);
    }
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();

}
