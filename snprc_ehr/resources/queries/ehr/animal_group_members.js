/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true
    });
}

var cachedGroups = {};

function onUpsert(helper, scriptErrors, row, oldRow){
    // If we don't have the RowId of the group, try resolving it based on the category and name
    if(!row.GroupId && row.GroupCategory && row.GroupName) {
        var cacheKey = row.GroupCategory + '~~~~~' + row.GroupName;
        row.GroupId = cachedGroups[cacheKey];
        if (row.GroupId === undefined || row.GroupId == 'undefined')
        {
            LABKEY.Query.selectRows({
                schemaName: 'ehr',
                queryName: 'animal_groups',
                columns: 'RowId',
                scope: this,
                filterArray: [
                    LABKEY.Filter.create('Category', row.GroupCategory, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('Name', row.GroupName, LABKEY.Filter.Types.EQUAL)
                ],
                success: function (data)
                {
                    if (data.rows && data.rows.length)
                    {
                        row.GroupId = data.rows[0].rowid;
                        cachedGroups[cacheKey] = row.GroupId;
                        console.log('caching ' + cacheKey + ': ' + row.GroupId);
                    }
                },
                failure: function (error)
                {
                    console.log('Select rows error');
                    console.log(error);
                }
            });
        }

    }
}
