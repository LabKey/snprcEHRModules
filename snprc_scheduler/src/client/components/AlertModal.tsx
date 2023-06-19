import React, { FC, memo, ReactNode } from 'react';
import { Button, Modal } from 'react-bootstrap';

export interface AlertModalProps {
    msg: ReactNode;
    onDismiss: () => void;
    show: boolean;
    title: ReactNode;
}

export const AlertModal: FC<AlertModalProps> = memo(({ show, title, msg, onDismiss }) => (
    <Modal show={show} onHide={onDismiss}>
        <Modal.Header closeButton>
            <Modal.Title>{title}</Modal.Title>
        </Modal.Header>

        <Modal.Body>
            <p>{msg}</p>
        </Modal.Body>

        <Modal.Footer>
            <Button bsClass={'btn btn-danger'} onClick={onDismiss}>OK</Button>
        </Modal.Footer>
    </Modal>
));

AlertModal.displayName = 'AlertModal';
