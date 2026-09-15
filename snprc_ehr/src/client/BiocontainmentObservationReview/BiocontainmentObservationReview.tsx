import React, { useEffect, useRef, useState } from 'react';
import { ActionURL } from '@labkey/api';
import { Alert } from '@labkey/components';
import { Col, Row } from 'react-bootstrap';
import { approveObservations, fetchObservation, ObservationRow } from './api/observation';
import { Reload, ReviewGridPanel } from './components/ReviewGridPanel';
import ObservationDetail from './components/ObservationDetail';
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

const errorText = (error: any): string => error?.exception ?? error?.message ?? 'Unexpected error';

const BiocontainmentObservationReview = () => {
    const [reload, setReload] = useState<Reload>({ key: 0, clearSelections: false });
    const [focusedLsid, setFocusedLsid] = useState<string>();
    const [focused, setFocused] = useState<ObservationRow>();
    const [message, setMessage] = useState('');
    const [error, setError] = useState('');
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
            setFocused(undefined);
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

    const onApprove = async (lsid: string) => {
        setError('');
        try {
            await approveObservations([lsid]);
            // Approved records leave the queue; close the record immediately rather than waiting for the grid to clear
            setFocusedLsid(undefined);
            setFocused(undefined);
            showMessage('Observation approved.');
            reloadGrid(true);
        } catch (e) {
            // Author-as-approver and missing-role rejections arrive here from the server
            setError(errorText(e));
        }
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
                    <Alert className="review-alert" bsStyle="success">{message}</Alert>
                    <Alert className="review-alert">{error}</Alert>
                </Col>
            </Row>
            <Row className="observation-review__panels">
                <Col xs={12} lg={5} className="observation-review__grid">
                    <ReviewGridPanel reload={reload} onApprove={onApprove} onFocus={setFocusedLsid} />
                </Col>
                <Col xs={12} lg={7} className="observation-review__detail">
                    {focused
                        ? <ObservationDetail key={focused.lsid} row={focused} onSaved={onSaved} />
                        : <h3 className="observation-review__placeholder">☑ Select an observation to see the full record.</h3>}
                </Col>
            </Row>
            <Row>
                <Col xs={12}>
                    <a className="observation-review__footer-link" href={RECENTLY_APPROVED_URL}>
                        View observations approved in the last 7 days
                    </a>
                </Col>
            </Row>
        </div>
    );
};

export default BiocontainmentObservationReview;
