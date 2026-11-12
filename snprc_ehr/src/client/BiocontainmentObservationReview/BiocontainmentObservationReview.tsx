import React, { useEffect, useRef, useState } from 'react';
import { ActionURL } from '@labkey/api';
import { Alert } from '@labkey/components';
import { Col, Row } from 'react-bootstrap';
import { approveObservation, fetchObservation, ObservationRow } from './api/observation';
import { Reload, ReviewGridPanel } from './components/ReviewGridPanel';
import ObservationDetail from './components/ObservationDetail';
import { errorText } from './services/errorText';
import { missingFields } from './constants/fields';
import './styles/biocontainmentObservationReview.scss';

const MESSAGE_TIMEOUT_MS = 30000;

// Default dataset grid filtered to observations approved in the last 7 days, newest first
const RECENTLY_APPROVED_URL = ActionURL.buildURL('query', 'executeQuery', undefined, {
    schemaName: 'study',
    'query.queryName': 'BiocontainmentObservations',
    'query.QCState/Label~eq': 'Completed',
    'query.reviewedDate~dategte': '-7d',
    'query.sort': '-reviewedDate',
});

const BiocontainmentObservationReview = () => {
    const [reload, setReload] = useState<Reload>({ key: 0, clearSelections: false });
    const [focusedLsid, setFocusedLsid] = useState<string>();
    const [focused, setFocused] = useState<ObservationRow>();
    const [message, setMessage] = useState('');
    const [error, setError] = useState('');
    const [isEditing, setIsEditing] = useState(false);
    const messageTimer = useRef<number>();

    // Success messages clear themselves; errors stay until the next action
    const showMessage = (text: string) => {
        window.clearTimeout(messageTimer.current);
        setMessage(text);
        messageTimer.current = window.setTimeout(() => setMessage(''), MESSAGE_TIMEOUT_MS);
    };

    useEffect(() => () => window.clearTimeout(messageTimer.current), []);

    const reloadGrid = (clearSelections: boolean) => setReload(r => ({ key: r.key + 1, clearSelections }));

    useEffect(() => {
        if (!focusedLsid) {
            return;
        }
        // A slower fetch for a record that has since been approved or deselected must not reopen it
        let isCurrent = true;
        fetchObservation(focusedLsid)
            .then(row => isCurrent && setFocused(row))
            .catch(e => isCurrent && setError(errorText(e)));
        return () => {
            isCurrent = false;
        };
    }, [focusedLsid, reload]);

    const record = focused && focused.lsid === focusedLsid ? focused : undefined;
    // The server rejects these approvals, so don't offer them: a missing value must be corrected first,
    // and without the version on screen the server can't confirm the reviewer saw the current record
    const canApprove = !!record && !isEditing && !!record.modified && missingFields(record).length === 0;

    const onApprove = async (lsid: string) => {
        // Approve only the record on screen, at the version the reviewer saw
        if (!canApprove || record.lsid !== lsid) return;
        setError('');
        try {
            await approveObservation(lsid, record.modified);
            // Approved records leave the queue; close the record immediately rather than waiting for the grid to clear
            setFocusedLsid(undefined);
            showMessage('Observation approved.');
            reloadGrid(true);
        } catch (e) {
            // Author-as-approver, missing-role and changed-since-opened rejections arrive here from the server.
            // A record that changed is out of date on screen, so fetch the current version; reloading after the others is harmless.
            setError(errorText(e));
            reloadGrid(false);
        }
    };

    // An error belongs to the record it came from, so selecting another record clears it;
    // reloading the same record keeps it (e.g. "changed after you opened it")
    const onFocus = (lsid: string | undefined) => {
        if (lsid !== focusedLsid) setError('');
        setFocusedLsid(lsid);
    };

    const onSaved = () => {
        setError('');
        showMessage('Correction saved. The observation needs approval again.');
        reloadGrid(false);
    };

    return (
        <div className="observation-review">
            <Row>
                <Col xs={12}>
                    <p className="review-instructions">
                        Select an observation to see the full record. Approve only observations you have checked.
                    </p>
                    <Alert bsStyle="success" className="review-alert">
                        {message}
                    </Alert>
                    <Alert className="review-alert">{error}</Alert>
                </Col>
            </Row>
            <Row className="observation-review__panels">
                <Col className="observation-review__grid" lg={5} xs={12}>
                    <ReviewGridPanel canApprove={canApprove} onApprove={onApprove} onFocus={onFocus} reload={reload} />
                </Col>
                <Col className="observation-review__detail" lg={7} xs={12}>
                    {record ? (
                        <ObservationDetail
                            key={record.lsid}
                            onEditingChange={setIsEditing}
                            onSaved={onSaved}
                            row={record}
                        />
                    ) : (
                        <h3 className="observation-review__placeholder">
                            ☑ Select an observation to see the full record.
                        </h3>
                    )}
                </Col>
            </Row>
            <Row>
                <Col xs={12}>
                    <a className="observation-review__footer-link" href={RECENTLY_APPROVED_URL}>
                        View observations approved in the last 7 days.
                    </a>
                </Col>
            </Row>
        </div>
    );
};

export default BiocontainmentObservationReview;
