/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by thawkins on 9/29/2018.
 */

require("ehr/triggers").initScript(this);
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);


function onInit(event, helper) {
    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true
    });
}

function onUpsert(helper, scriptErrors, row, oldRow) {

    if (row.code === 0) {
        row.code = snprcTriggerHelper.getNextAnimalGroup();
    }

    var message = undefined;

    // if there is an endDate, it must be >= startDate (date)
    if (row.enddate) {

        var startDate = new Date(row.date);
        var endDate = new Date(row.enddate);

        if (startDate > endDate) {
            message = 'End date must occur on or after the start date.';
            EHR.Server.Utils.addError(scriptErrors, 'enddate', message, 'ERROR');

        }
    }

    // //Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies.
    // if (row.category_code) {
    //     if (row.category_code < 11) {
    //         message = 'Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies.';
    //         EHR.Server.Utils.addError(scriptErrors, 'category_code', message, 'ERROR');
    //     }
    // }

    // enddate changes
    var old_enddate, new_enddate;
    if (message === undefined && oldRow && row.enddate) {

        if (oldRow.enddate === undefined) {
            old_enddate = new Date(row.enddate)
        }
        else {
            var d = oldRow.enddate.split("-");
            old_enddate = new Date(d[0], d[1] - 1, d[2]);
        }

        new_enddate = new Date(row.enddate);

        if ((row.enddate && oldRow.enddate === undefined) || (new_enddate.getTime() !== old_enddate.getTime())) {

            // can't end date an entry that still has active group members
            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'animal_group_members',
                scope: this,
                filterArray: [
                    LABKEY.Filter.create('groupId', row.code, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.MISSING)
                ],
                success: function (data) {
                    if (data.rows && data.rows.length) {
                        message = "Group has active members that must be end dated first."
                    }
                },
                failure: function (error) {
                    message = 'Error reading from study.animal_group_members table';
                }
            });

            if (message) {
                EHR.Server.Utils.addError(scriptErrors, 'enddate', message, 'ERROR');
            }

            // End date must be greater than or equal to the max end date for assigned group members
            if (message === undefined) {
                LABKEY.Query.selectRows({
                    schemaName: 'study',
                    queryName: 'MaxEndDateForAnimalGroup',
                    columns: 'groupid',
                    scope: this,
                    filterArray: [
                        LABKEY.Filter.create('groupId', row.groupId, LABKEY.Filter.Types.EQUAL),
                        LABKEY.Filter.create('enddate', row.enddate, LABKEY.Filter.Types.GREATER_THAN)
                    ],
                    success: function (data) {
                        if (data.rows && data.rows.length > 0) {
                            message = "End date must be greater than or equal to the max end date for assigned group members."
                        }
                    },
                    failure: function (error) {
                        message = 'Error reading from study.animal_group_members table';
                    }
                });

                if (message) {
                    if (message) {
                        EHR.Server.Utils.addError(scriptErrors, 'enddate', message, 'ERROR');
                    }
                }
            }
        }
    }
}