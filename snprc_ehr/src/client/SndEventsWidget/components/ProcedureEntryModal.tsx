import React, { FC, memo, useEffect, useState } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Alert, WizardNavButtons } from '@labkey/components';

interface Props {
    show: boolean,
    onCancel: () => any,
    eventId: string
}
export const ProcedureEntryModal: FC<Props> = memo((props: Props) => {
    const { show, onCancel, eventId } = props;
    //const [children, setChildren] = useState<any>();

    useEffect(() => {
        const script = document.createElement('script');
        script.src = '/labkey/snprc_mobile/app/widget.js'
        script.type = 'application/javascript'

        script.onload = () => {
            const ProcedureEntryWidget = document.getElementById('procedure-entry-widget')
            ProcedureEntryWidget.setAttribute('data-event-id', eventId)
            //setChildren(ProcedureEntryWidget.children)
        }
        document.getElementById("modal-body").insertBefore(script, document.getElementById("modal-body").firstChild)

        return () => {
            document.getElementById("modal-body").removeChild(script);
        };

    }, [])

    // useEffect(() => {
    //     if(children[0].hasOwnProperty('children')) {
    //         console.log(children[0].children)
    //     }
    // }, [children])

    return (
        <Modal id="widget-modal" className="widget-modal" show={show} onHide={onCancel} >
            <Modal.Body id="modal-body" className="widget-modal-body">
                <div id="procedure-entry-widget" data-event-id={eventId}></div>
            </Modal.Body>
        </Modal>
    )
});