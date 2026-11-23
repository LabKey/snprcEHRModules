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

// Trimmed text, with empty and blank both meaning "no value"
function trimmed(value){
    var text = value == null ? '' : String(value).trim();
    return text === '' ? null : text;
}

function sameNumber(a, b){
    return (a == null || a === '' || b == null || b === '') ? sameValue(a, b) : Number(a) === Number(b);
}

function sameCarryOver(a, b){
    return !!Number(a) === !!Number(b);
}

// Milliseconds for a date, a Java date, or LabKey's 'yyyy-MM-dd HH:mm:ss.SSS' string; NaN if it can't be read.
// Rhino 1.7R3 can't parse that string, and new Date(javaDate) drops the milliseconds, so neither is used.
function toMillis(value){
    if (value == null)
        return NaN;
    if (typeof value.getTime === 'function')
        return Number(value.getTime());
    var m = /^(\d{4})[-\/](\d{1,2})[-\/](\d{1,2})[ T](\d{1,2}):(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?/.exec(String(value));
    if (!m)
        return NaN;
    var ms = m[7] ? Number((m[7] + '00').substring(0, 3)) : 0;
    return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]), Number(m[4]), Number(m[5]), Number(m[6] || 0), ms).getTime();
}

function changedFields(row, oldRow){
    return SCORED_FIELDS.filter(function(field){
        var co = CARRY_OVER[field];
        return !sameValue(row[field], oldRow[field]) || (co && !sameCarryOver(row[co], oldRow[co]));
    });
}

// Compared to the second: EHR drops the milliseconds from row.date before this trigger runs, but oldRow.date keeps them
function sameDate(a, b){
    var x = toMillis(a), y = toMillis(b);
    return isNaN(x) || isNaN(y) ? sameValue(a, b) : Math.floor(x / 1000) === Math.floor(y / 1000);
}

// Everything else the approver signed for: the animal, date, location, comment and every reason
function recordChanged(row, oldRow){
    return trimmed(row.Id) !== trimmed(oldRow.Id)
        || !sameDate(row.date, oldRow.date)
        || !sameNumber(row.Location, oldRow.Location)
        || trimmed(row.Comment) !== trimmed(oldRow.Comment)
        || SCORED_FIELDS.some(function(field){
            return trimmed(row[field + 'Comments']) !== trimmed(oldRow[field + 'Comments']);
        });
}

var SIGNATURE_FIELDS = ['reviewedBy', 'reviewedByName', 'reviewedDate', 'reviewMeaning'];

// Copies the signature from another row, or clears it when from is null
function setSignature(row, from){
    SIGNATURE_FIELDS.forEach(function(f){
        row[f] = from ? from[f] : null;
    });
}

function clearReview(row){
    row.QCStateLabel = REVIEW_REQUIRED;
    setSignature(row, null);
}

// Every scored parameter on the form must have a value (LabKey checks this as well as CAMP)
function requireValues(scriptErrors, row){
    SCORED_FIELDS.forEach(function(field){
        if (row[field] == null || row[field] === '')
            EHR.Server.Utils.addError(scriptErrors, field, 'A value is required for ' + field, 'ERROR');
    });
}

function onInsert(helper, scriptErrors, row){
    requireValues(scriptErrors, row);
    clearReview(row);
}

function onUpdate(helper, scriptErrors, row, oldRow){
    var changed = changedFields(row, oldRow);
    // These need no reason of their own (the comment is free text, and a reason explains itself),
    // but changing any of them is still a modification to approve
    var otherChange = recordChanged(row, oldRow);

    if (helper.isETL()){
        // A re-merge with identical values (e.g. after the write-back export) must not undo an approval
        if (changed.length || otherChange)
            clearReview(row);
        else
            row.QCStateLabel = oldRow.QCStateLabel;
        return;
    }

    requireValues(scriptErrors, row);

    if (changed.length || otherChange){
        // An approval must never quietly become "not approved": the reviewer is told, whether the change is real or a bug
        if (row.QCStateLabel === COMPLETED && oldRow.QCStateLabel !== COMPLETED){
            EHR.Server.Utils.addError(scriptErrors, 'QCStateLabel', 'This observation has changes that must be saved before it can be approved.', 'ERROR');
            return;
        }

        // Trimmed, so a reason of only spaces is no reason, the same rule the page applies
        changed.forEach(function(field){
            var reason = trimmed(row[field + 'Comments']);
            if (!reason)
                EHR.Server.Utils.addError(scriptErrors, field + 'Comments', 'A reason is required for each changed value', 'ERROR');
            else if (reason === trimmed(oldRow[field + 'Comments']))
                EHR.Server.Utils.addError(scriptErrors, field + 'Comments', 'Enter a new reason; this one was given for an earlier change', 'ERROR');
            else
                row[field + 'Comments'] = reason;
        });

        // The approver approves the record and any modification (9/1 decision 6)
        clearReview(row);
        return;
    }

    // Not approved (sent back for review by hand, or any other state): the old signature no longer applies
    if (row.QCStateLabel !== COMPLETED){
        setSignature(row, null);
        return;
    }

    // Already approved and still approved: the signature can't be edited
    if (oldRow.QCStateLabel === COMPLETED){
        setSignature(row, oldRow);
        return;
    }

    // Approval: the only place the signature is set

    // The reviewer must have seen the version being approved; EHR fills in modified, so it is sent under its own name
    var viewed = toMillis(row.viewedModified);
    if (isNaN(viewed) || viewed !== toMillis(oldRow.modified)){
        EHR.Server.Utils.addError(scriptErrors, 'QCStateLabel', 'This observation changed after you opened it. Check the current version and approve again.', 'ERROR');
        return;
    }

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