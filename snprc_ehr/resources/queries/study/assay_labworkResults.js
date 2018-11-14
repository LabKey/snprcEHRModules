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
            // console.log("Cache hit: " + cachedIds[cacheKey]);
        }

    }
}

function assignServiceTestId (row, serviceId, testid ) {

    var result = true;

    LABKEY.Query.selectRows({
        schemaName: 'snprc_ehr',
        queryName: 'labwork_panels',
        columns: 'RowId',
        scope: this,
        filterArray: [
            LABKEY.Filter.create('ServiceId', serviceId, LABKEY.Filter.Types.EQUAL),
            LABKEY.Filter.create('TestId', testid, LABKEY.Filter.Types.EQUAL)
        ],
        success: function (data) {
            if (data.rows && data.rows.length) {
                row.serviceTestId = data.rows[0].RowId;
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