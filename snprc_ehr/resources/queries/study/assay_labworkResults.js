/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

/**
 * Created by thawkins on 6/29/2017.  Cloned for assay_labworkResults by Charles Peterson on 11/1/18.
 */

require("ehr/triggers").initScript(this);

var cachedIds = {};
var cacheKey = '';
let runIdCache = {};

// the missing value codes will link the record up to an unknown service (needed for ancient legacy data)
var missingServiceId = 999999;
var missingTestId = 999999;

function onUpsert(helper, scriptErrors, row, oldRow) {
    // If we don't have the serviceTestId try resolving it based on the testId and serviceId
    if (!row.serviceTestId) {
        cacheKey = row.serviceid + '~' + row.testid;
        row.serviceTestId = cachedIds[cacheKey];
        if (row.serviceTestId === undefined || row.serviceTestId == 'undefined') {
            if (!assignServiceTestId(row, row.serviceId, row.testId)) {
                // point the serviceTestId to a missing value type if the serviceId/testId is missing
                // in the snprc_ehr.labkey_panels table
                assignServiceTestId(row, missingServiceId, missingTestId);
            }
        }
        else
        {
             //console.log("Cache hit: " + cachedIds[cacheKey]);
        }

    }
    if (!row.runId) {
        row.runId = runIdCache[row.sampleId];

        if (row.runId === undefined || row.runId == 'undefined') {
                assignRunId(row, row.sampleId);
        }
        else
        {
             //console.log("RunId Cache hit: " + runIdCache[row.sampleId]);
        }
    }
}

function assignServiceTestId (row, serviceId, testid ) {

    var result = true;

    LABKEY.Query.selectRows({
        schemaName: 'snprc_ehr',
        queryName: 'labwork_panels',
        columns: 'ObjectId',
        scope: this,
        filterArray: [
            LABKEY.Filter.create('ServiceId', serviceId, LABKEY.Filter.Types.EQUAL),
            LABKEY.Filter.create('TestId', testid, LABKEY.Filter.Types.EQUAL)
        ],
        success: function (data) {
            if (data.rows && data.rows.length) {
                row.serviceTestId = data.rows[0].ObjectId;
                cachedIds[cacheKey] = row.serviceTestId;
                //console.log('caching ' + cacheKey + ': ' + row.serviceTestId);

            }
            else {
                result = false;
            }

        },
        failure: function (error) {
            console.log('Select rows error');
            console.log(error);
        }

    });
    return result;
}

function assignRunId (row, sampleId ) {

    let result = true;

    LABKEY.Query.selectRows({
        schemaName: 'study',
        queryName: 'assay_clinpathRuns',
        columns: '_key',
        scope: this,
        filterArray: [
            LABKEY.Filter.create('sampleId', sampleId, LABKEY.Filter.Types.EQUAL)
        ],
        success: function (data) {
            if (data.rows && data.rows.length) {
                row.runId = data.rows[0]._key;
                runIdCache[row.sampleId] = row.runId;
            }
            else {
                result = false;
            }
        },
        failure: function (error) {
            console.log('Select rows error');
            console.log(error);
        }
    });
    return result;
}