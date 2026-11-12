import React, { useEffect, useState } from 'react';
import { Button, OverlayTrigger, Tooltip } from 'react-bootstrap';
import { Correction, correctObservation, fetchPriorObservation, historyUrl, ObservationRow } from '../api/observation';
import { formatDateTime } from '../services/formatDate';
import { formScore, scoreLabel } from '../services/clinicalScore';
import {
    fieldsFor,
    HUSBANDRY_FIELDS,
    HusbandryField,
    isMissingValue,
    missingFields,
    NOT_APPLICABLE,
} from '../constants/fields';
import { errorText } from '../services/errorText';

interface Props {
    onEditingChange: (editing: boolean) => void;
    onSaved: () => void;
    row: ObservationRow;
}

const priorTooltip = <Tooltip id="prior-history-tooltip">View prior observation history</Tooltip>;

// LabKey returns numbers and the selects return strings; null, undefined and '' all mean no value
const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

// Carry-over and NS flags: empty and 0 both mean No
const sameFlag = (a: unknown, b: unknown) => !!Number(a) === !!Number(b);
const yesNo = (value: unknown) => (Number(value) ? 'Yes' : 'No');

const husbandryLabel = (h: HusbandryField, value: unknown) =>
    h.options.find(o => String(o.value) === text(value))?.label ?? NOT_APPLICABLE;

const FORM_NAMES = { '15PT': '15-point', '4PT': '4-point (ABSL-4)' };

const ObservationDetail = ({ row, onSaved, onEditingChange }: Props) => {
    const [isEditing, setIsEditing] = useState(false);
    const [edits, setEdits] = useState<Record<string, Correction>>({});
    const [errorMessage, setErrorMessage] = useState('');
    const [prior, setPrior] = useState<ObservationRow>();
    // undefined until the comment is edited
    const [comment, setComment] = useState<string>();

    const isFourPoint = row.FormType === '4PT';
    const fields = fieldsFor(row.FormType);
    const fieldOf = (name: string) => fields.find(f => f.name === name);

    // A carry-over or NS flag shares its parameter's reason, so changing either one needs it
    const isChanged = (e: Correction) => {
        const f = fieldOf(e.field);
        return (
            text(e.value) !== text(row[e.field]) ||
            (f?.carryOver !== undefined && !sameFlag(e.carryOver, row[f.carryOver])) ||
            (f?.notSedated !== undefined && !sameFlag(e.notSedated, row[f.notSedated]))
        );
    };
    const changed = Object.values(edits).filter(isChanged);

    // The values as they will be saved; the score follows unsaved edits, as the tablet's does while values are picked
    const edited = Object.values(edits).reduce<ObservationRow>((r, e) => {
        const f = fieldOf(e.field);
        return {
            ...r,
            [e.field]: e.value,
            ...(f?.carryOver ? { [f.carryOver]: e.carryOver } : {}),
            ...(f?.notSedated ? { [f.notSedated]: e.notSedated } : {}),
        };
    }, row);

    // On the 4-point form, FD leaves the rest of the form empty (10/13). On the 15-point form a deceased animal's
    // observation is still fully recorded (10/20), so Found Dead is just another value there.
    const foundDead = isFourPoint && Number(edited.FoundDead) === 1;
    const isNotSedated = (name: string) => {
        const ns = fieldOf(name)?.notSedated;
        return ns !== undefined && Number(edited[ns]) === 1;
    };

    // Switching FD on a 4-point record clears or reopens every scored field, so those fields can use FD's reason
    const foundDeadChanged = isFourPoint && changed.some(e => e.field === 'FoundDead');
    const foundDeadReason = edits.FoundDead?.reason?.trim() ?? '';
    const sharesFoundDeadReason = (field: string) => foundDeadChanged && fieldOf(field) !== undefined;
    const reasonOf = (e: Correction) => e.reason?.trim() || (sharesFoundDeadReason(e.field) ? foundDeadReason : '');
    // A reason must be new: the stored one belongs to an earlier change, and the server rejects it
    const missingReason = changed.filter(e => {
        const reason = reasonOf(e);
        return !reason || reason === text(row[`${e.field}Comments`]).trim();
    });

    // Every field is required (5/08, 10/13), except on a 4-point FD record and Dehydration when NS. The server rejects
    // a save while any value is missing, even one the reviewer didn't touch.
    const stillMissing = missingFields(edited);
    const missingValue = stillMissing.map(f => f.name);
    const isMissing = (field: string) => isMissingValue(row[field]);

    // The comment is free text, so it is its own reason; changing it still sends the record back for approval
    const commentChanged = comment !== undefined && comment.trim() !== (row.Comment ?? '');
    const hasChanges = changed.length > 0 || commentChanged;

    // A correction reloads the row but never moves it, so the prior only changes with the animal, location or date
    useEffect(() => {
        let isCurrent = true;
        fetchPriorObservation(row)
            .then(p => isCurrent && setPrior(p))
            .catch(e => isCurrent && setErrorMessage(errorText(e, 'Could not load the prior observation')));
        return () => {
            isCurrent = false;
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps -- the prior only depends on animal, location and date
    }, [row.Id, row.Location, row.date]);

    const unedited = (field: string): Correction => {
        const f = fieldOf(field);
        return {
            field,
            value: row[field],
            carryOver: f?.carryOver ? row[f.carryOver] : undefined,
            notSedated: f?.notSedated ? row[f.notSedated] : undefined,
            reason: '',
        };
    };

    // The page disables Approve while a correction is open; the cleanup re-enables it when the record closes
    useEffect(() => {
        onEditingChange(isEditing);
        return () => onEditingChange(false);
        // eslint-disable-next-line react-hooks/exhaustive-deps -- onEditingChange is a state setter
    }, [isEditing]);

    const setEdit = (field: string, patch: Partial<Correction>) => {
        setEdits({ ...edits, [field]: { ...unedited(field), ...edits[field], ...patch } });
    };

    const setFoundDead = (value: string) => {
        const next = { ...edits, FoundDead: { ...unedited('FoundDead'), ...edits.FoundDead, value } };
        if (isFourPoint) {
            fields.forEach(f => {
                if (value === '1') {
                    next[f.name] = {
                        ...unedited(f.name),
                        ...edits[f.name],
                        value: null,
                        ...(f.notSedated ? { notSedated: null } : {}),
                    };
                    return;
                }
                // Turning FD off again drops what it cleared, so any recorded values show again
                if (edits[f.name] && text(edits[f.name].value) === '') delete next[f.name];
                // A record that was saved as FD has no NS answer yet; it is required once the animal is observed
                if (f.notSedated && text(row[f.notSedated]) === '')
                    next[f.name] = { ...unedited(f.name), ...next[f.name], notSedated: 0 };
            });
        }
        setEdits(next);
    };

    const setNotSedated = (field: string, value: string) => {
        // NS leaves Dehydration empty; turning it off asks for a value again
        setEdit(field, { notSedated: Number(value), ...(value === '1' ? { value: null } : {}) });
    };

    const onSave = async () => {
        setErrorMessage('');
        try {
            await correctObservation(
                row.lsid,
                changed.map(e => ({ ...e, reason: reasonOf(e) })),
                commentChanged ? comment.trim() : undefined
            );
            setEdits({});
            setComment(undefined);
            setIsEditing(false);
            onSaved();
        } catch (error) {
            setErrorMessage(errorText(error, 'Save failed'));
        }
    };

    const reasonCell = (field: string) => (
        <td className={missingReason.some(e => e.field === field) ? 'needs-reason' : undefined}>
            {isEditing ? (
                <input
                    className="form-control"
                    maxLength={128}
                    onChange={e => setEdit(field, { reason: e.target.value })}
                    placeholder={sharesFoundDeadReason(field) && foundDeadReason ? 'Same as Found Dead' : undefined}
                    value={edits[field]?.reason ?? ''}
                />
            ) : (
                row[`${field}Comments`]
            )}
        </td>
    );

    const priorValue = (field: string) => {
        if (isFourPoint && Number(prior.FoundDead) === 1) return NOT_APPLICABLE;
        const ns = fieldOf(field)?.notSedated;
        if (ns && Number(prior[ns]) === 1) return 'NS';
        return prior[field] ?? '-';
    };

    return (
        <div className="panel panel-default observation-detail">
            <div className="panel-heading">
                {row.Id} · Location {row.Location} · {formatDateTime(row.date)}
            </div>
            <div className="panel-body">
                <p>Recorded by {row['createdBy/DisplayName']}</p>
                {row.FormType && (
                    <p className="observation-form">
                        {FORM_NAMES[row.FormType] ?? row.FormType} form ({row.FormCode})
                    </p>
                )}
                <table className="table table-condensed">
                    <thead>
                        <tr>
                            <th>Parameter</th>
                            {/* Hidden when there is no prior, as on the tablet */}
                            {prior && (
                                <th className="prior-value">
                                    <OverlayTrigger overlay={priorTooltip} placement="top">
                                        <a href={historyUrl(row)} rel="noopener noreferrer" target="_blank">
                                            Prior
                                        </a>
                                    </OverlayTrigger>
                                </th>
                            )}
                            <th>Value</th>
                            <th>{isFourPoint ? 'Not sedated' : 'Carry over'}</th>
                            <th>Reason for change</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Found Dead</td>
                            {prior && <td className="prior-value">{yesNo(prior.FoundDead)}</td>}
                            <td>
                                {isEditing ? (
                                    <select
                                        className="form-control"
                                        onChange={e => setFoundDead(e.target.value)}
                                        value={Number(edited.FoundDead) ? '1' : '0'}
                                    >
                                        <option value="1">Yes</option>
                                        <option value="0">No</option>
                                    </select>
                                ) : (
                                    yesNo(row.FoundDead)
                                )}
                            </td>
                            <td />
                            {reasonCell('FoundDead')}
                        </tr>
                        {fields.map(f => (
                            <tr key={f.name}>
                                <td>{f.label}</td>
                                {prior && <td className="prior-value">{priorValue(f.name)}</td>}
                                <td className={isEditing && missingValue.includes(f.name) ? 'needs-value' : undefined}>
                                    {foundDead ? (
                                        NOT_APPLICABLE
                                    ) : isNotSedated(f.name) ? (
                                        'NS'
                                    ) : isEditing ? (
                                        <select
                                            className="form-control"
                                            onChange={e => setEdit(f.name, { value: e.target.value })}
                                            value={text(edited[f.name])}
                                        >
                                            {/* A missing value shows as blank, not as the first choice, and can't be chosen */}
                                            {text(edited[f.name]) === '' && (
                                                <option disabled value="">
                                                    Select a value
                                                </option>
                                            )}
                                            {f.values.map(v => (
                                                <option key={v} value={String(v)}>
                                                    {v}
                                                </option>
                                            ))}
                                        </select>
                                    ) : isMissing(f.name) ? (
                                        <span className="text-danger">Missing</span>
                                    ) : (
                                        row[f.name]
                                    )}
                                </td>
                                <td>
                                    {f.carryOver &&
                                        (isEditing ? (
                                            <select
                                                className="form-control"
                                                onChange={e => setEdit(f.name, { carryOver: Number(e.target.value) })}
                                                value={Number(edited[f.carryOver]) ? '1' : '0'}
                                            >
                                                <option value="1">Yes</option>
                                                <option value="0">No</option>
                                            </select>
                                        ) : (
                                            yesNo(row[f.carryOver])
                                        ))}
                                    {f.notSedated &&
                                        !foundDead &&
                                        (isEditing ? (
                                            <select
                                                className="form-control"
                                                onChange={e => setNotSedated(f.name, e.target.value)}
                                                value={Number(edited[f.notSedated]) ? '1' : '0'}
                                            >
                                                <option value="1">Yes</option>
                                                <option value="0">No</option>
                                            </select>
                                        ) : (
                                            yesNo(row[f.notSedated])
                                        ))}
                                </td>
                                {reasonCell(f.name)}
                            </tr>
                        ))}
                    </tbody>
                </table>
                {/* Calculated from the values above, never entered */}
                <p className="clinical-score">
                    {`${scoreLabel(row.FormType)}: `}
                    <strong>{formScore(edited)}</strong>
                    {prior && <span className="prior-value"> (prior {formScore(prior)})</span>}
                </p>
                {/* Not scored, and no prior value (9/29) */}
                <table className="table table-condensed husbandry">
                    <thead>
                        <tr>
                            <th>Husbandry</th>
                            <th>Value</th>
                            <th>Reason for change</th>
                        </tr>
                    </thead>
                    <tbody>
                        {HUSBANDRY_FIELDS.map(h => (
                            <tr key={h.name}>
                                <td>{h.label}</td>
                                <td>
                                    {isEditing ? (
                                        <select
                                            className="form-control"
                                            onChange={e => setEdit(h.name, { value: e.target.value })}
                                            value={text(edited[h.name])}
                                        >
                                            <option value="">{NOT_APPLICABLE}</option>
                                            {h.options.map(o => (
                                                <option key={o.value} value={String(o.value)}>
                                                    {o.label}
                                                </option>
                                            ))}
                                        </select>
                                    ) : (
                                        husbandryLabel(h, row[h.name])
                                    )}
                                </td>
                                {reasonCell(h.name)}
                            </tr>
                        ))}
                    </tbody>
                </table>
                {isEditing ? (
                    <div className="form-group">
                        <label htmlFor="observation-comment">Comment</label>
                        <input
                            className="form-control"
                            id="observation-comment"
                            maxLength={80}
                            onChange={e => setComment(e.target.value)}
                            value={comment ?? row.Comment ?? ''}
                        />
                    </div>
                ) : (
                    <p>Comment: {row.Comment}</p>
                )}
                {isEditing && stillMissing.length > 0 && (
                    <p className="text-danger">
                        Fill in every missing value before saving: {stillMissing.map(f => f.label).join(', ')}.
                    </p>
                )}
                {errorMessage && <p className="text-danger">{errorMessage}</p>}
                {isEditing ? (
                    <>
                        <Button
                            bsStyle="success"
                            disabled={!hasChanges || missingReason.length > 0 || missingValue.length > 0}
                            onClick={onSave}
                        >
                            Save correction
                        </Button>
                        <Button
                            onClick={() => {
                                setEdits({});
                                setComment(undefined);
                                setErrorMessage('');
                                setIsEditing(false);
                            }}
                        >
                            Cancel
                        </Button>
                    </>
                ) : (
                    <Button onClick={() => setIsEditing(true)}>Edit Values</Button>
                )}
            </div>
        </div>
    );
};

export default ObservationDetail;
