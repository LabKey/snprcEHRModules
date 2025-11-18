import React from 'react';
import {Button, Modal} from "react-bootstrap";

interface AlertModalProps {
    show: boolean;
    title: string;
    msg: string;
    onDismiss: (() => void) | null;
}

const AlertModal: React.FC<AlertModalProps> = ({ show, title, msg, onDismiss }) => {
    return (
        <Modal show={show} onHide={onDismiss} animation={false}>
            <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
                <p>{msg}</p>
            </Modal.Body>

            <Modal.Footer>
                <Button className='btn btn-danger' onClick={onDismiss}>OK</Button>
            </Modal.Footer>
        </Modal>
    );
};

export default AlertModal;
