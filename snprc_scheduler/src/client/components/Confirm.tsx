import React, { FC } from 'react';
import { Button, Modal } from 'react-bootstrap';

interface ConfirmProps {
    cancelButtonText: string;
    confirmButtonText: string;
    confirmVariant: string;
    msg: string;
    onCancel: (() => void) | null;
    onConfirm: (() => void) | null;
    show: boolean;
    title: string;
}

const Confirm: FC<ConfirmProps> = ({
    show,
    title,
    msg,
    onConfirm,
    onCancel,
    confirmButtonText,
    cancelButtonText,
    confirmVariant,
}) => {
    return (
        <Modal animation={false} onHide={onCancel} show={show}>
            <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
                <p>{msg}</p>
            </Modal.Body>

            <Modal.Footer>
                <Button className="btn btn-light" onClick={onCancel}>
                    {cancelButtonText}
                </Button>
                <Button className={'btn btn-' + confirmVariant} onClick={onConfirm}>
                    {confirmButtonText}
                </Button>
            </Modal.Footer>
        </Modal>
    );
};

export default Confirm;
