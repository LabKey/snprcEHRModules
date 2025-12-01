import React, { FC } from 'react';
import { Button, Modal } from 'react-bootstrap';

interface AlertModalProps {
    msg: string;
    onDismiss: (() => void) | null;
    show: boolean;
    title: string;
}

const AlertModal: FC<AlertModalProps> = ({ show, title, msg, onDismiss }) => {
    return (
        <Modal animation={false} onHide={onDismiss} show={show}>
            <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
                <p>{msg}</p>
            </Modal.Body>

            <Modal.Footer>
                <Button className="btn btn-danger" onClick={onDismiss}>
                    OK
                </Button>
            </Modal.Footer>
        </Modal>
    );
};

export default AlertModal;
