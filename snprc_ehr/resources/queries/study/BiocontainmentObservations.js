/*
 * Copyright (c) 2026 SNPRC
 */
require("ehr/triggers").initScript(this);

// The 13 scored parameters on TXB 904-1 — each carries its own reason comment (9/1 decision 7)
var SCORED_FIELDS = ['WeightLoss', 'TemperatureChange', 'Responsiveness', 'HairCoat', 'Respiration', 'Petechia',
    'Bleeding', 'NasalDischarge', 'FeedEaten', 'FoodEnrichment', 'Stool', 'FluidIntake', 'Dehydration'];

var REVIEW_REQUIRED = 'Review Required';
var COMPLETED = 'Completed';

function sameValue(a, b){
    return (a == null ? null : String(a)) === (b == null ? null : String(b));
}

function changedFields(row, oldRow){
    return SCORED_FIELDS.filter(function(field){
        return !sameValue(row[field], oldRow[field]);
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
    // A CAMP record is not public until a second person has reviewed it; the EHR default would make it Completed
    if (helper.isETL())
        clearReview(row);
}

function onUpdate(helper, scriptErrors, row, oldRow){
    var changed = changedFields(row, oldRow);

    if (helper.isETL()){
        // A re-merge with identical values (e.g. after the write-back export) must not undo an approval
        if (changed.length)
            clearReview(row);
        return;
    }

    if (changed.length){
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

        // Stamped here, never taken from the client
        row.reviewedBy = user.id;
        row.reviewedByName = user.displayName;
        row.reviewedDate = new Date();
        row.reviewMeaning = 'Reviewed and approved';
    }
}