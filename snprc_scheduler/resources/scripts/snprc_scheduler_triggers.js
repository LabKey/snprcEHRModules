exports.init = function (EHR) {

    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function (event, helper, EHR) {

        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'blood', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.AFTER_DELETE);
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('study', 'cases', EHR.Server.TriggerManager.Events.AFTER_UPSERT);
    });

};