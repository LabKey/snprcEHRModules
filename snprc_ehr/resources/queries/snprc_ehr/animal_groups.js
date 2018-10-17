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

    var errors = validate(row, oldRow);

    if (errors) {
        scriptErrors[errors['field']] = [];
        scriptErrors[errors['field']].push({
            message: errors['message'],
            severity: errors['severity']
        });
    }
}


function validate(row, oldRow) {

    var errors = {};

    // if there is an endDate, it must be >= startDate (date)
    if (row.enddate) {


        var startDate = new Date(row.date);
        var endDate = new Date(row.enddate);
        if (startDate > endDate) {
            errors = {
                field: 'enddate',
                message: 'End date must occur on or after the start date.',
                severity: 'ERROR'
            };
        }
    }

    //Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies.
    if (row.category_code) {
        if (row.category_code < 11) {
            errors = {
                field: 'category_code',
                message: 'Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies. Updates are not permitted.',
                severity: 'ERROR'
            };
        }
    }

    // enddate changes
    var old_enddate, new_enddate;
    if (oldRow && row.enddate) {

        if ( oldRow.enddate === undefined) {
            old_enddate = new Date(row.enddate)
        }
        else {
            var d = oldRow.enddate.split("-");
            old_enddate = new Date(d[0], d[1] - 1, d[2]);
        }

        new_enddate = new Date(row.enddate);

        if ((row.enddate && oldRow.enddate === undefined) || (new_enddate.getTime() !== old_enddate.getTime())) {

            // can't end date an entry that still has active group members
            var message = undefined;

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
                errors = {
                    field: 'category_code',
                    message: message,
                    severity: 'ERROR'
                };
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
            }
            if (message) {
                errors = {
                    field: 'category_code',
                    message: message,
                    severity: 'ERROR'
                };
            }
        }
    }

    return (Object.keys(errors).length > 0) ? errors : undefined;
}