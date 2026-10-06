/*
 * Copyright (c) 2026 SNPRC
 */
require("ehr/triggers").initScript(this);

// The 13 scored parameters on TXB 904-1 — each carries its own reason comment (9/1 decision 7)
var SCORED_FIELDS = ['WeightLoss', 'TemperatureChange', 'Responsiveness', 'HairCoat', 'Respiration', 'Petechia',
    'Bleeding', 'NasalDischarge', 'FeedEaten', 'FoodEnrichment', 'Stool', 'FluidIntake', 'Dehydration'];

// Carry-over shares its parameter's reason column, so a carry-over change counts as a change to that parameter
var CARRY_OVER = {WeightLoss: 'WeightLossCO', TemperatureChange: 'TemperatureChangeCO', Petechia: 'PetechiaCO',
    FeedEaten: 'FeedEatenCO', FoodEnrichment: 'FoodEnrichmentCO', Dehydration: 'DehydrationCO'};

var REVIEW_REQUIRED = 'Review Required';
var COMPLETED = 'Completed';

function sameValue(a, b){
    return (a == null ? null : String(a)) === (b == null ? null : String(b));
}

function sameCarryOver(a, b){
    return !!Number(a) === !!Number(b);
}

function changedFields(row, oldRow){
    return SCORED_FIELDS.filter(function(field){
        var co = CARRY_OVER[field];
        return !sameValue(row[field], oldRow[field]) || (co && !sameCarryOver(row[co], oldRow[co]));
    });
}

function clearReview(row){
    row.QCStateLabel = REVIEW_REQUIRED;
    row.reviewedBy = null;
    row.reviewedByName = null;
    row.reviewedDate = null;
    row.reviewMeaning = null;
}

function onInsert(helper, scriptErrors, row){
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

    if (changed.length || commentChanged){
        changed.forEach(function(field){
            var reason = row[field + 'Comments'];
            if (!reason || sameValue(reason, oldRow[field + 'Comments']))
                EHR.Server.Utils.addError(scriptErrors, field + 'Comments', 'A reason is required for each changed value', 'ERROR');
        });

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