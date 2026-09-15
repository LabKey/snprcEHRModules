import React, { useState } from 'react';
import { Button } from 'react-bootstrap';
import { Correction, correctObservation, ObservationRow } from '../api/observation';
import { formatDateTime } from '../services/formatDate';
import { SCORED_FIELDS } from '../constants/fields';

interface Props {
    row: ObservationRow;
    onSaved: () => void;
}

const ObservationDetail = ({row, onSaved}: Props) => {
    const [isEditing, setIsEditing] = useState(false);
    const [edits, setEdits] = useState<Record<string, Correction>>({});
    const [errorMessage, setErrorMessage] = useState('');

    const changed = Object.values(edits).filter(e => String(e.value) !== String(row[e.field]));
    const missingReason = changed.filter(e => !e.reason?.trim());

    const setEdit = (field: string, patch: Partial<Correction>) =>
        setEdits({ ...edits, [field]: {field, value: row[field], reason: '', ...edits[field], ...patch}});

    const onSave = async () => {
        setErrorMessage('');
        try {
            await correctObservation(row.lsid, changed);
            setEdits({});
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
                    <tr><th>Parameter</th><th>Score</th><th>Carry over</th><th>Reason for change</th></tr>
                    </thead>
                    <tbody>
                    {SCORED_FIELDS.map(f => (
                        <tr key={f.name}>
                            <td>{f.label}</td>
                            <td>
                                {isEditing
                                    ? (
                                        <select
                                            className="form-control"
                                            value={String(edits[f.name]?.value ?? row[f.name] ?? '')}
                                            onChange={e => setEdit(f.name, { value: e.target.value })}
                                        >
                                            {f.values.map(v => <option key={v} value={String(v)}>{v}</option>)}
                                        </select>
                                    )
                                    : row[f.name]}
                            </td>
                            <td>{f.carryOver ? (row[f.carryOver] ? 'Yes' : 'No') : ''}</td>
                            <td className={missingReason.some(e => e.field === f.name) ? 'needs-reason' : undefined}>
                                {isEditing
                                    ? <input className="form-control" maxLength={128} value={edits[f.name]?.reason ?? ''} onChange={e => setEdit(f.name, { reason: e.target.value })} />
                                    : row[`${f.name}Comments`]}
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>
                <p>Comment: {row.Comment}</p>
                {errorMessage && <p className="text-danger">{errorMessage}</p>}
                {isEditing ? (
                    <>
                        <Button bsStyle="success" disabled={!changed.length || missingReason.length > 0} onClick={onSave}>
                            Save correction
                        </Button>
                        <Button onClick={() => { setEdits({}); setIsEditing(false); }}>Cancel</Button>
                    </>
                ) : (
                    <Button onClick={() => setIsEditing(true)}>Edit Values</Button>
                )}
            </div>
        </div>
    )
}

export default ObservationDetail;