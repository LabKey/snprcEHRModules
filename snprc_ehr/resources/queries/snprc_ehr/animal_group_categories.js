/**
 * Created by thawkins on 10/15/2018.
 */

require("ehr/triggers").initScript(this);
var snprcTriggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);


function onInit(event, helper) {

    console.log('animal_group_categories.js onInit() called.');

    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true


    });
}

function onUpsert(helper, scriptErrors, row, oldRow) {

    var errors = validate(row, oldRow);

    if (errors) {
        scriptErrors[errors['field']] = [];
        scriptErrors[errors['field']].push({
            message: errors['message'],
            severity: errors['severity']
        });
    }
    if (row.category_code === 0) {
        row.code = snprcTriggerHelper.getNextAnimalGroupCategory();
    }
}


function validate(row, oldRow) {

    var errors = {};

    // category 0 = inserting new record
    if (row.category_code === 0) {

        console.log('category code is ZERO');
    }

    //Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies.
    if (row.category_code < 11) {
        errors = {
            field: 'category_code',
            message: 'Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies. Updates are not permitted.',
            severity: 'ERROR'
        };

        console.log('category code is less than 11');
    }


    if (oldRow) {

        //gender changes
        {

            console.log('Checking gender...');

            var old_sex = (oldRow.sex === undefined) ? 'N/A' : oldRow.sex;
            var new_sex = (row.sex === undefined || row.sex === '' || row.sex === null) ? 'N/A' : row.sex;

            if (old_sex !== new_sex && new_sex !== 'N/A') {
                // if sex changes we need to make sure that members are the correct gender

                var message = undefined;

                LABKEY.Query.executeSql({
                    schemaName: 'study',
                    sql: "SELECT 1 FROM study.animal_group_members as agm" +
                            " JOIN snprc_ehr.animal_groups as ag ON agm.groupId = ag.code and ag.category_code = " + row.category_code +
                            " WHERE  agm.id.demographics.gender <> '" + new_sex + "'",
                    scope: this,
                    success: function (data) {
                        console.log('')
                        if (data.rows && data.rows.length > 0) {
                            message = "Group has member(s) with a gender mismatch.";
                        }
                    },
                    failure: function (error) {
                        console.log('error = ' + error.exception || error.statusText || error.msg || error.message || '');
                        message = 'Error reading from study.animal_group_members table';
                    }
                });

                if (message) {
                    errors = {
                        field: 'gender',
                        message: message,
                        severity: 'ERROR'
                    };
                }
            }
        }
        // "enforce_exclusivity" change
        {
            console.log('Checking exclusivity...');

            var old_enforce_exclusivity = (oldRow.enforce_exclusivity === undefined) ? 'N' : oldRow.enforce_exclusivity;
            var new_enforce_exclusivity = (row.enforce_exclusivity === undefined || row.enforce_exclusivity === '' || row.enforce_exclusivity === null) ? 'N' : row.enforce_exclusivity;

            if (old_enforce_exclusivity === 'N' && new_enforce_exclusivity === 'Y') {
                // if enforce_exclusivity changes from N to Y, then we need to make sure that members are only assigned to one group

                var message = undefined;

                LABKEY.Query.executeSql({
                    schemaName: 'study',
                    sql: "SELECT 1 FROM study.animal_group_members as agm" +
                            " JOIN snprc_ehr.animal_groups as ag ON agm.groupId = ag.code and ag.category_code = " + row.category_code +
                            " WHERE  agm.enddate is NULL" +
                            " GROUP BY id " +
                            " HAVING count(*) > 1",
                    scope: this,
                    success: function (data) {
                        console.log('')
                        if (data.rows && data.rows.length > 0) {
                            message = "Enforce exclusivity cannot be changed because animal(s) are currently assigned to multiple groups.";
                        }
                    },
                    failure: function (error) {
                        console.log('error = ' + error.exception || error.statusText || error.msg || error.message || '');
                        message = 'Error reading from study.animal_group_members table';
                    }
                });

                if (message) {
                    errors = {
                        field: 'enforce_exclusivity',
                        message: message,
                        severity: 'ERROR'
                    };
                }
            }
        }
        // allow_future_date change
        {
            console.log('Checking future dates...');

            var old_allow_future_date = (oldRow.allow_future_date === undefined) ? 'N' : oldRow.allow_future_date;
            var new_allow_future_date = (row.allow_future_date === undefined || row.allow_future_date === '' || row.allow_future_date === null) ? 'N' : row.allow_future_date;

            if (old_allow_future_date === 'Y' && new_allow_future_date === 'N') {
                // if allow_future_date changes from N to Y, then we need to make sure that no members are assigned or end dated in the future

                var message = undefined;

                LABKEY.Query.executeSql({
                    schemaName: 'study',
                    sql: "SELECT 1 FROM study.animal_group_members as agm" +
                            " JOIN snprc_ehr.animal_groups as ag ON agm.groupId = ag.code and ag.category_code = " + row.category_code +
                            " WHERE COALESCE(agm.enddate, now()) > now() OR COALESCE(agm.date, now()) > now()",
                    scope: this,
                    success: function (data) {
                        console.log('')
                        if (data.rows && data.rows.length > 0) {
                            message = "Allow Future Dates cannot be changed because animal(s) are already assigned or end dated in the future.";
                        }
                    },
                    failure: function (error) {
                        console.log('error = ' + error.exception || error.statusText || error.msg || error.message || '');
                        message = 'Error reading from study.animal_group_members table';
                    }
                });

                if (message) {
                    errors = {
                        field: 'allow_future_date',
                        message: message,
                        severity: 'ERROR'
                    };
                }
            }
        }

        // species change
        {
            console.log('Checking future dates...');

            var old_species = (oldRow.species === undefined) ? 'N/A' : oldRow.species;
            var new_species = (row.species === undefined || row.species === '' || row.species === null) ? 'N/A' : row.species;

            if (old_species !== 'N/A' && old_species !== new_species) {
                // if species changes, then we need to make sure that no members are currently assigned to category

                var message = undefined;

                LABKEY.Query.executeSql({
                    schemaName: 'study',
                    sql: "SELECT 1 FROM study.animal_group_members as agm" +
                            " JOIN snprc_ehr.animal_groups as ag ON agm.groupId = ag.code and ag.category_code = " + row.category_code,
                    scope: this,
                    success: function (data) {
                        if (data.rows && data.rows.length > 0) {
                            message = "Species cannot be changed because animal(s) are already assigned to this category.";
                        }
                    },
                    failure: function (error) {
                        console.log('error = ' + error.exception || error.statusText || error.msg || error.message || '');
                        message = 'Error reading from study.animal_group_members table';
                    }
                });

                if (message) {
                    errors = {
                        field: 'species',
                        message: message,
                        severity: 'ERROR'
                    };
                }
            }
        }
        return (Object.keys(errors).length > 0) ? errors : undefined;
    }
}