/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");

// For more complicated logic, I highly recommend implementing this in java.  This provides much better debugging, and the full use of the server-side java APIs
// Methods on this TriggerHelper can be called from JS, and can return values to the JS code.  In general, I try to only pass primitives; however, that may not always be required

var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

exports.init = function (EHR) {


    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function (event, helper, EHR) {

        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'Departure', EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC);

        EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Departure', function (scriptErrors, helper, row, oldRow) {
            helper.registerDeparture(row.Id, row.date);
            //Check whether 'Assignment', 'Cases', 'Housing', 'Treatment Orders', 'Notes', 'Problem List' should be closed
            var shouldCloseDataSets = snprcTriggerHelper.shouldCloseDataSets(row.Id, row.date);
            if (shouldCloseDataSets) {
                //this will close any existing assignments, housing and treatment records
                helper.onDeathDeparture(row.Id, row.date);
            }

        });

        // remove clinpathRuns trigger event handlers (defined in ehr/clinpathRuns.js)
         EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'clinpathRuns', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);

        // remove cases trigger event handlers (defined in ehr module)
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.AFTER_DELETE);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.AFTER_UPSERT);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'blood', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'flags', EHR.Server.TriggerManager.Events.AFTER_INSERT);
    });

};