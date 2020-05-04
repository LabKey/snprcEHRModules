/*
 * Copyright (c) 2010-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        allowAnyId: true,
        requiresStatusRecalc: true
    });
}

function onUpsert(helper, scriptErrors, row, oldRow){
    if (!helper.isETL()) {

        // check if animal has open housing record
        if (row.Id) {
            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'housing',
                columns: ['Id'],
                scope: this,
                filterArray: [
                    LABKEY.Filter.create('Id', row.Id),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)
                ],
                success: function (results) {
                    if (results && (results.rows) && (results.rows.length > 0)) {
                        EHR.Server.Utils.addError(scriptErrors, 'Id', 'Animal ID ' + row.Id + ' has an open housing record. It must be closed before this arrival can be submitted', 'WARN');
                    }
                },
                failure: function (error) {
                    console.log('Select rows error in NewAnimalData.js');
                    console.log(error);
                }
            });
        }

        // check acquisition date
        if (row.date) {
            var acquisitionDate = new Date(row.date);
            var now = new Date();
            if (acquisitionDate > now)
                EHR.Server.Utils.addError(scriptErrors, 'date', 'Future acquisition date is not allowed', 'ERROR');
        }

        // check dam and sire
        if (row.dam) {
            EHR.Server.Utils.findDemographics({
                participant: row.dam,
                helper: helper,
                scope: this,
                callback: function (data) {
                    if (data && (data.calculated_status !== 'Alive'))
                        EHR.Server.Utils.addError(scriptErrors, 'dam', 'Status of Female ' + row.dam + ' is: ' + data.calculated_status, 'INFO');
                    if (data && data['gender/origGender'] && (data['gender/origGender'] !== 'F'))
                        EHR.Server.Utils.addError(scriptErrors, 'dam', 'Dam ' + row.dam + ' is not female gender', 'ERROR');
                }
            });
        }
        if (row.sire) {
            EHR.Server.Utils.findDemographics({
                participant: row.sire,
                helper: helper,
                scope: this,
                callback: function (data) {
                    if (data && (data.calculated_status !== 'Alive'))
                        EHR.Server.Utils.addError(scriptErrors, 'sire', 'Status of Male ' + row.sire + ' is: ' + data.calculated_status, 'INFO');
                    if (data && data['gender/origGender'] && (data['gender/origGender'] !== 'M'))
                        EHR.Server.Utils.addError(scriptErrors, 'sire', 'Sire ' + row.sire + ' is not male gender', 'ERROR');
                }
            });
        }
    }
}

// mostly from EHR's arrival.js
EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Arrival', function(scriptErrors, helper, row, oldRow) {
    helper.registerArrival(row.Id, row.date);

    //if not already present, we insert into demographics
    if (!helper.isETL() && !helper.isGeneratedByServer()){
        row.genNum = '0';  // all arrivals in CNPRC are currently acquisitions from other centers, so their genNum is 0
        var birthErrors = helper.getJavaHelper().onAnimalArrival(row.id, row, helper.getExtraBirthFieldMappings(), helper.getExtraDemographicsFieldMappings());
        if (birthErrors){
            EHR.Server.Utils.addError(scriptErrors, 'birth', birthErrors, 'ERROR');
        }

        //if room provided, we insert into housing
        if (row.initialRoom){
            helper.getJavaHelper().createHousingRecord(row.Id, row.date, null, row.initialRoom, (row.initialCage || null), (row.initialCond || null));
        }
    }
});
