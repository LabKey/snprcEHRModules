import React, { FC, memo, useEffect, useState } from 'react';
import { Modal } from 'react-bootstrap';
import { Alert } from '@labkey/components';

interface Props {
    show: boolean,
    onCancel: () => any,
    onSuccess: (message) => any,
    eventId?: string,
    subjectId?: string
}
export const ProcedureEntryModal: FC<Props> = memo((props: Props) => {
    const { show, onCancel, onSuccess, eventId, subjectId } = props;

    useEffect(() => {
        const script = document.createElement('script');
        script.src = '/labkey/snprc_mobile/app/widget.js'
        script.type = 'application/javascript'

        script.onload = () => {
            const ProcedureEntryWidget = document.getElementById('procedure-entry-widget')
            if (eventId) {
                ProcedureEntryWidget.setAttribute('data-event-id', eventId)
            } else if (subjectId) {
                ProcedureEntryWidget.setAttribute('data-subject-id', subjectId)
            }
            window.addEventListener('saveEventSuccess', handleSaveEventSuccess);

        }

        const handleBodyClick = (event: Event) => {
            let targetElement = event.target as HTMLElement; // Casting to HTMLElement
            if (targetElement && (targetElement.className.includes("widget-cancel") || targetElement.parentElement.className.includes("widget-cancel"))) {
                onCancel();
            }
        };

        const handleSaveEventSuccess = (event) => {
            onSuccess(event.detail.message);
        }

        document.body.addEventListener('click', handleBodyClick);

        document.getElementById("modal-body").insertBefore(script, document.getElementById("modal-body").firstChild)

        return () => {
            document.getElementById("modal-body").removeChild(script);
        };

    }, [])



    return (
        <Modal backdrop="static" keyboard={false} id="widget-modal" className="widget-modal" show={show} onHide={onCancel} >
            <Modal.Body id="modal-body" className="widget-modal-body">
                {eventId && (
                    <div id="procedure-entry-widget" data-event-id={eventId}></div>
                )}
                {!eventId && subjectId && (
                    <div id="procedure-entry-widget" data-subject-id={subjectId}></div>
                )}
            </Modal.Body>
        </Modal>
    )
});