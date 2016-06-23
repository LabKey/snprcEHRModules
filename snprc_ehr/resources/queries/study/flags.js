/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

var triggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function onInit(event, helper){
    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true,
        removeTimeFromEndDate: true
    });
}

// var cachedAttribs = {};  tjh

function onUpsert(helper, scriptErrors, row, oldRow)
{

/*

 // flag field was changed to an integer value and fk to flag_values was changed to the 'code' field.
 // This may change in the future.  Please do not delete the commented out code below.  tjh
 //
    var cacheKey = row.attribute;

    // If we don't have the PK (flag_values.objectid) for the attribute, resolve it based on the attribute value
    if (!row.flag && row.attribute)
    {

        row.flag = cachedAttribs[cacheKey];
        if (row.flag === undefined || row.flag == 'undefined')
        {
            LABKEY.Query.selectRows({
                schemaName: 'ehr_lookups',
                queryName: 'flag_values',
                columns: 'objectid',
                scope: this,
                filterArray: [
                    LABKEY.Filter.create('value', row.attribute, LABKEY.Filter.Types.EQUAL)
                ],
                success: function (data)
                {
                    if (data.rows && data.rows.length)
                    {
                        row.flag = data.rows[0].objectid;
                        cachedAttribs[cacheKey] = row.flag;
                        console.log('caching ' + cacheKey + ': ' + row.flag);
                    }
                },
                failure: function (error)
                {
                    console.log('Select rows error');
                    console.log(error);
                }
            });
        }
        else {
            console.log('Cache hit: ' + row.attribute);
        }
    }

  */
        //if the animal is not at the center, automatically set the enddate
        if (!helper.isETL() && row.Id && !row.enddate){
            EHR.Server.Utils.findDemographics({
                participant: row.Id,
                helper: helper,
                scope: this,
                callback: function(data){
                    if (!data)
                        return;

                    if (data && data.calculated_status && data.calculated_status != 'Alive'){
                        row.enddate = data.death || data.departure;
                    }
                }
            });

        }
    if (!helper.isETL() && row.Id && row.date && row.flag && row.objectid)
    {
        var active = helper.getJavaHelper().getOverlappingFlags(row.Id, row.flag, row.objectid || null, row.date);
        if (active > 0)
        {
            EHR.Server.Utils.addError(scriptErrors, 'flag', 'There are already ' + active + ' active flag(s) of the same type spanning this date.', 'INFO');
        }
    }
}


function onAfterInsert(helper, errors, row){

    //if this category enforces only a single active flag at once, enforce it
    //note: if this flag has a future date, preemptively set enddate on flags, since isActive should handle this
    if (!helper.isETL() && row.Id && row.flag && !row.enddate && row.date){
        triggerHelper.ensureSingleFlagCategoryActive(row.Id, row.flag, row.objectId, row.date);
    }
}