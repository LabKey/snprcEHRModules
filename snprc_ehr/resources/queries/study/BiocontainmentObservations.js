/*
 * Copyright (c) 2026 SNPRC
 */
require("ehr/triggers").initScript(this);

// Fields that carry their own reason comment (9/1 decision 7). Cage Cleaning and Water are reviewable with a
// reason but never scored (9/29); FoundDead is the 4-point form's FD and the 15-point form's Deceased (10/20).
var REASON_FIELDS = ['FoundDead', 'WeightLoss', 'TemperatureChange', 'Responsiveness', 'HairCoat', 'Respiration', 'Petechia',
    'Bleeding', 'NasalDischarge', 'FeedEaten', 'FoodEnrichment', 'Stool', 'FluidIntake', 'Dehydration', 'CageCleaning', 'Water'];

// Flags that share their parameter's reason column, so changing one counts as a change to that parameter.
// DehydrationNS is the 4-point form's "not sedated"; the 15-point form records dehydration with a carry-over instead.
var LINKED_FLAGS = {WeightLoss: ['WeightLossCO'], TemperatureChange: ['TemperatureChangeCO'], Petechia: ['PetechiaCO'],
    FeedEaten: ['FeedEatenCO'], FoodEnrichment: ['FoodEnrichmentCO'], Dehydration: ['DehydrationCO', 'DehydrationNS']};

// Allowed values per form, mirroring the CK_* constraints on CAMP's dbo.BiocontainmentObservation.
// A field missing from a form's list isn't on that form and must be empty.
var STOOL = ['0', '1', '2D', '2R'];
var FORMS = {
    '15PT': {
        FormCode: 'TXB904-1-R01',
        FoundDead: [0, 1], WeightLoss: [0, 1, 2], WeightLossCO: [0, 1], TemperatureChange: [0, 1, 2, 3], TemperatureChangeCO: [0, 1],
        Responsiveness: [0, 1, 2, 8, 15], HairCoat: [0, 1], Respiration: [0, 8, 15], Petechia: [0, 1, 2, 3], PetechiaCO: [0, 1],
        Bleeding: [0, 1, 2], NasalDischarge: [0, 1], FeedEaten: [0, 1], FeedEatenCO: [0, 1], FoodEnrichment: [0, 1],
        FoodEnrichmentCO: [0, 1], Stool: STOOL, FluidIntake: [0, 1, 2], Dehydration: [0, 1], DehydrationCO: [0, 1]
    },
    '4PT': {
        FormCode: 'TXB904-1-ABSL4-R00',
        FoundDead: [0, 1], Responsiveness: [0, 1, 2, 3, 4], HairCoat: [0, 1], Respiration: [0, 1, 2], Petechia: [0, 1, 2, 3],
        Bleeding: [0, 1, 2], NasalDischarge: [0, 1], Stool: STOOL, FluidIntake: [0, 1, 2], Dehydration: [0, 1], DehydrationNS: [0, 1]
    }
};
var FORM_FIELDS = ['FoundDead', 'WeightLoss', 'WeightLossCO', 'TemperatureChange', 'TemperatureChangeCO', 'Responsiveness',
    'HairCoat', 'Respiration', 'Petechia', 'PetechiaCO', 'Bleeding', 'NasalDischarge', 'FeedEaten', 'FeedEatenCO',
    'FoodEnrichment', 'FoodEnrichmentCO', 'Stool', 'FluidIntake', 'Dehydration', 'DehydrationCO', 'DehydrationNS'];
// Both forms, never scored and optional: empty is N/A
var HUSBANDRY = {CageCleaning: [1, 2], Water: [1, 2]};

var REVIEW_REQUIRED = 'Review Required';
var COMPLETED = 'Completed';

function sameValue(a, b){
    return (a == null ? null : String(a)) === (b == null ? null : String(b));
}

function sameFlag(a, b){
    return !!Number(a) === !!Number(b);
}

function isEmpty(value){
    return value === null || value === undefined || value === '';
}

function isAllowed(value, allowed){
    return allowed.map(String).indexOf(String(value)) !== -1;
}

function changedFields(row, oldRow){
    return REASON_FIELDS.filter(function(field){
        return !sameValue(row[field], oldRow[field]) || (LINKED_FLAGS[field] || []).some(function(flag){
            return !sameFlag(row[flag], oldRow[flag]);
        });
    });
}

// Same rules as CAMP's CHECK constraints, so a bad correction fails here instead of at the TAC to CAMP fan-out
function validateForm(scriptErrors, row){
    var form = FORMS[row.FormType];
    if (!form){
        EHR.Server.Utils.addError(scriptErrors, 'FormType', 'Unknown form type: ' + row.FormType, 'ERROR');
        return;
    }
    if (row.FormCode !== form.FormCode)
        EHR.Server.Utils.addError(scriptErrors, 'FormCode', 'Form code ' + row.FormCode + ' does not match form type ' + row.FormType, 'ERROR');

    // On the 4-point form, FD leaves the rest empty and NS leaves Dehydration empty (10/13).
    // On the 15-point form a deceased animal's observation is still fully recorded (10/20).
    var foundDead = row.FormType === '4PT' && Number(row.FoundDead) === 1;
    var notSedated = row.FormType === '4PT' && Number(row.DehydrationNS) === 1;

    FORM_FIELDS.forEach(function(field){
        var allowed = form[field];
        var mustBeEmpty = !allowed || (foundDead && field !== 'FoundDead') || (notSedated && field === 'Dehydration');
        if (mustBeEmpty){
            if (!isEmpty(row[field]))
                EHR.Server.Utils.addError(scriptErrors, field, field + ' is not recorded here and must be empty', 'ERROR');
        }
        else if (isEmpty(row[field]) || !isAllowed(row[field], allowed)){
            EHR.Server.Utils.addError(scriptErrors, field, field + ' must be one of: ' + allowed.join(', '), 'ERROR');
        }
    });

    for (var field in HUSBANDRY){
        if (!isEmpty(row[field]) && !isAllowed(row[field], HUSBANDRY[field]))
            EHR.Server.Utils.addError(scriptErrors, field, field + ' must be empty (N/A) or one of: ' + HUSBANDRY[field].join(', '), 'ERROR');
    }
}

function clearReview(row){
    row.QCStateLabel = REVIEW_REQUIRED;
    row.reviewedBy = null;
    row.reviewedByName = null;
    row.reviewedDate = null;
    row.reviewMeaning = null;
}

function onInsert(helper, scriptErrors, row){
    // ETL rows already passed CAMP's CHECK constraints, and one rejection here would fail the whole batch
    if (!helper.isETL())
        validateForm(scriptErrors, row);
    clearReview(row);
}

function onUpdate(helper, scriptErrors, row, oldRow){
    var changed = changedFields(row, oldRow);
    // The comment is free text and needs no separate reason, but changing it is still a modification to approve
    var commentChanged = !sameValue(row.Comment, oldRow.Comment);

    if (helper.isETL()){
        // A re-merge with identical values (e.g. after the write-back export) must not undo an approval
        if (changed.length || commentChanged)
            clearReview(row);
        else
            row.QCStateLabel = oldRow.QCStateLabel;
        return;
    }

    // The form an observation was recorded on never changes
    if (!sameValue(row.FormCode, oldRow.FormCode) || !sameValue(row.FormType, oldRow.FormType)){
        EHR.Server.Utils.addError(scriptErrors, 'FormType', 'The form an observation was recorded on cannot be changed', 'ERROR');
        return;
    }

    if (changed.length || commentChanged){
        changed.forEach(function(field){
            var reason = row[field + 'Comments'];
            if (!reason || sameValue(reason, oldRow[field + 'Comments']))
                EHR.Server.Utils.addError(scriptErrors, field + 'Comments', 'A reason is required for each changed value', 'ERROR');
        });
        validateForm(scriptErrors, row);

        // The approver approves the record and any modification (9/1 decision 6)
        clearReview(row);
        return;
    }

    if (row.QCStateLabel === COMPLETED && oldRow.QCStateLabel !== COMPLETED){
        var user = LABKEY.Security.currentUser;

        if (sameValue(user.id, oldRow.createdBy)){
            EHR.Server.Utils.addError(scriptErrors, 'QCStateLabel', 'This observation must be reviewed by someone other than its author', 'ERROR');
            return;
        }

        // Printed name for the signature record (REQ-028), read in Java so approvers don't need permission to see user details
        var triggerHelper = new org.labkey.snprc_ehr.query.SNPRC_EHRTriggerHelper(user.id, LABKEY.Security.currentContainer.id);
        var printedName = String(triggerHelper.getPrintedName());

        row.reviewedBy = user.id;
        row.reviewedByName = printedName;
        row.reviewedDate = new Date();
        row.reviewMeaning = 'Reviewed and approved';
    }
}