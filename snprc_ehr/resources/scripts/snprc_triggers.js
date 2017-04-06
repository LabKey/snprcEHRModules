var console = require("console");
var LABKEY = require("labkey");

// For more complicated logic, I highly recommend implementing this in java.  This provides much better debugging, and the full use of the server-side java APIs
// Methods on this TriggerHelper can be called from JS, and can return values to the JS code.  In general, I try to only pass primitives; however, that may not always be required
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);


exports.init = function(EHR){

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'Departure', function(event, helper, EHR) {
        helper.setScriptOptions({
            datasetsToClose: ['Assignment', 'Cases', 'Housing', 'Treatment Orders', 'Notes', 'Problem List']
        });
    });

    // TODO: The following code is example code for registering new events for datasets, validation and error reporting, and using
    // java to enhance your trigger scripts.
    // EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Departure', function(helper, scriptErrors, row, oldRow) {
    //     console.log('Hello world!');
    //
    //     if (row.foo == 'something suspicious'){
    //         EHR.Server.Utils.addError(scriptErrors, 'foo', 'You entered a suspicious value for the field foo.  This is just a warning and will not block the user from saving the form.', 'WARN');
    //     }
    //     else if (row.foo == 'bad'){
    //         EHR.Server.Utils.addError(scriptErrors, 'foo', 'Do not enter a value of "bad" for the field foo.  On most forms you can save the data, but in most cases you cannot finalize the form until this has been corrected.  Some power users have permission to submit forms anyway in this condition.', 'WARN');
    //     }
    //     else if (row.foo == 'really bad'){
    //         EHR.Server.Utils.addError(scriptErrors, 'foo', 'Do not enter a value of "really bad" for the field foo.  This is an error and usually the user cannot override/ignore this.', 'ERROR');
    //     }
    //
    //     var msg = snprcTriggerHelper.runSomeJavaCode(row.Id, row.date);
    //     if (msg){
    //         EHR.Server.Utils.addError(scriptErrors, 'Id', msg, 'ERROR');
    //     }
    // });
    //
    // EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function(event, helper, EHR) {
    //     console.log('I will be called for all tables!');
    //
    //     helper.setScriptOptions({
    //         //make global changes...
    //     });
    //
    //     //I can override methods in EHR!
    //     EHR.Server.Utils.isLiveBirth = function(birthCondition){
    //         //though this particular one probably isnt a very good change to make...
    //         return true;
    //     };
    // });
};