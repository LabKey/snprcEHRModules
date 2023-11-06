import React, { FC, memo, useEffect } from 'react';
import { Modal } from 'react-bootstrap';
import { Alert, WizardNavButtons } from '@labkey/components';

interface Props {
    show: boolean,
    onCancel: () => any,
    eventId: string
}
export const ProcedureEntryModal: FC<Props> = memo((props: Props) => {
    const { show, onCancel, eventId } = props;
    useEffect(() => {
        const widget = document.createElement('script');
        widget.src = '/labkey/snprc_mobile/app/widget.js'
        widget.type = "application/javascript";
        widget.async = true;
        document.body.appendChild(widget);
        const ProcedureEntryWidget = document.getElementById('procedure-entry-widget')
        ProcedureEntryWidget.setAttribute('data-event-id', eventId)

    }, [eventId])

    return (
        <Modal show={show} onHide={onCancel} className={'edit-modal'}>
            <Modal.Header closeButton>
                <Modal.Title>Procedure Entry</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <div id="procedure-entry-widget" data-event-id={eventId}></div>
            </Modal.Body>
            <Modal.Footer>
                {/*<WizardNavButtons containerClassName={''}*/}
                {/*                  cancel={onCancel}*/}
                {/*                  finish={table == 'Lookup' || row?.['IsInUse'] == 'false'}*/}
                {/*                  finishText={'Finish'}*/}
                {/*                  isFinishing={isSubmitting}*/}
                {/*                  isFinishingText={`Updating ${table}s`}*/}
                {/*                  nextStep={table == 'Lookup' || row?.['IsInUse'] == 'false' ? handleUpdate : onCancel}*/}
                {/*/>*/}
            </Modal.Footer>
        </Modal>

    )
});