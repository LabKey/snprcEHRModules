import React, { useEffect, useState } from 'react';
import { Button, OverlayTrigger, Tooltip } from 'react-bootstrap';
import { Correction, correctObservation, fetchPriorObservation, historyUrl, ObservationRow } from '../api/observation';
import { formatDateTime } from '../services/formatDate';
import { clinicalScore, displayScore } from '../services/clinicalScore';
import { carryOverOf, SCORED_FIELDS } from '../constants/fields';

interface Props {
    onSaved: () => void;
    row: ObservationRow;
}

const priorTooltip = <Tooltip id="prior-history-tooltip">View prior observation history</Tooltip>;

const ObservationDetail = ({ row, onSaved }: Props) => {
    const [isEditing, setIsEditing] = useState(false);
    const [edits, setEdits] = useState<Record<string, Correction>>({});
    const [errorMessage, setErrorMessage] = useState('');
    const [prior, setPrior] = useState<ObservationRow>();
    // undefined until the comment is edited
    const [comment, setComment] = useState<string>();

    // A carry-over shares its parameter's reason, so changing either one needs it. Empty and 0 both mean No.
    const sameCarryOver = (a: any, b: any) => !!Number(a) === !!Number(b);
    const isChanged = (e: Correction) => {
        const co = carryOverOf(e.field);
        return String(e.value) !== String(row[e.field]) || (co !== undefined && !sameCarryOver(e.carryOver, row[co]));
    };
    const changed = Object.values(edits).filter(isChanged);
    const missingReason = changed.filter(e => !e.reason?.trim());
    // The comment is free text, so it is its own reason; changing it still sends the record back for approval
    const commentChanged = comment !== undefined && comment.trim() !== (row.Comment ?? '');
    const hasChanges = changed.length > 0 || commentChanged;

    // The score follows unsaved edits, as the tablet's does while values are picked
    const edited = Object.values(edits).reduce<ObservationRow>((r, e) => ({ ...r, [e.field]: e.value }), row);

    // A correction reloads the row but never moves it, so the prior only changes with the animal, location or date
    useEffect(() => {
        let isCurrent = true;
        fetchPriorObservation(row)
            .then(p => isCurrent && setPrior(p))
            .catch(e => isCurrent && setErrorMessage(e?.exception ?? 'Could not load the prior observation'));
        return () => {
            isCurrent = false;
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps -- the prior only depends on animal, location and date
    }, [row.Id, row.Location, row.date]);

    const setEdit = (field: string, patch: Partial<Correction>) => {
        const co = carryOverOf(field);
        setEdits({
            ...edits,
            [field]: {
                field,
                value: row[field],
                carryOver: co ? row[co] : undefined,
                reason: '',
                ...edits[field],
                ...patch,
            },
        });
    };

    const onSave = async () => {
        setErrorMessage('');
        try {
            await correctObservation(row.lsid, changed, commentChanged ? comment.trim() : undefined);
            setEdits({});
            setComment(undefined);
            setIsEditing(false);
            onSaved();
        } catch (error) {
            setErrorMessage(error?.exception ?? 'Save failed');
        }
    };

    return (
        <div className="panel panel-default observation-detail">
            <div className="panel-heading">
                {row.Id} · Location {row.Location} · {formatDateTime(row.date)}
            </div>
            <div className="panel-body">
                <p>Recorded by {row['createdBy/DisplayName']}</p>
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
                            <th>Carry over</th>
                            <th>Reason for change</th>
                        </tr>
                    </thead>
                    <tbody>
                        {SCORED_FIELDS.map(f => (
                            <tr key={f.name}>
                                <td>{f.label}</td>
                                {prior && <td className="prior-value">{prior[f.name] ?? '-'}</td>}
                                <td>
                                    {isEditing ? (
                                        <select
                                            className="form-control"
                                            onChange={e => setEdit(f.name, { value: e.target.value })}
                                            value={String(edits[f.name]?.value ?? row[f.name] ?? '')}
                                        >
                                            {f.values.map(v => (
                                                <option key={v} value={String(v)}>
                                                    {v}
                                                </option>
                                            ))}
                                        </select>
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
                                                value={Number(edits[f.name]?.carryOver ?? row[f.carryOver]) ? '1' : '0'}
                                            >
                                                <option value="1">Yes</option>
                                                <option value="0">No</option>
                                            </select>
                                        ) : row[f.carryOver] ? (
                                            'Yes'
                                        ) : (
                                            'No'
                                        ))}
                                </td>
                                <td
                                    className={missingReason.some(e => e.field === f.name) ? 'needs-reason' : undefined}
                                >
                                    {isEditing ? (
                                        <input
                                            className="form-control"
                                            maxLength={128}
                                            onChange={e => setEdit(f.name, { reason: e.target.value })}
                                            value={edits[f.name]?.reason ?? ''}
                                        />
                                    ) : (
                                        row[`${f.name}Comments`]
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
                {/* Calculated from the values above, never entered */}
                <p className="clinical-score">
                    Clinical Score: <strong>{displayScore(clinicalScore(edited))}</strong>
                    {prior && <span className="prior-value"> (prior {displayScore(clinicalScore(prior))})</span>}
                </p>
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
                {errorMessage && <p className="text-danger">{errorMessage}</p>}
                {isEditing ? (
                    <>
                        <Button bsStyle="success" disabled={!hasChanges || missingReason.length > 0} onClick={onSave}>
                            Save correction
                        </Button>
                        <Button
                            onClick={() => {
                                setEdits({});
                                setComment(undefined);
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
