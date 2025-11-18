import React from 'react';
import { Button, Modal } from "react-bootstrap";

interface ConfirmProps {
    show: boolean;
    title: string;
    msg: string;
    onConfirm: (() => void) | null;
    onCancel: (() => void) | null;
    confirmButtonText: string;
    cancelButtonText: string;
    confirmVariant: string;
}

const Confirm: React.FC<ConfirmProps> = ({ show, title, msg, onConfirm, onCancel, confirmButtonText, cancelButtonText, confirmVariant }) => {
    return (
        <Modal show={show} onHide={onCancel} animation={false}>
            <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
                <p>{msg}</p>
            </Modal.Body>

            <Modal.Footer>
                <Button className='btn btn-light' onClick={onCancel}>{cancelButtonText}</Button>
                <Button className={'btn btn-' + confirmVariant} onClick={onConfirm}>{confirmButtonText}</Button>
            </Modal.Footer>
        </Modal>
    );
};

export default Confirm;
