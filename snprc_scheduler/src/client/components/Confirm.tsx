import React, { FC, memo, ReactNode } from 'react';
import { Button, Modal } from 'react-bootstrap';

export interface ConfirmProps {
    cancelButtonText: ReactNode;
    confirmButtonText: ReactNode;
    confirmVariant?: string;
    msg: ReactNode;
    onCancel: () => void;
    onConfirm: () => void;
    show: boolean;
    title: ReactNode;
}

export const Confirm: FC<ConfirmProps> = memo(props => {
    const { show, title, msg, onConfirm, onCancel, confirmButtonText, cancelButtonText, confirmVariant } = props;

    return (
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>{title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
                <p>{msg}</p>
            </Modal.Body>

            <Modal.Footer>
                <Button bsClass='btn btn-light' onClick={onCancel}>{cancelButtonText}</Button>
                <Button bsClass={'btn btn-' + confirmVariant} onClick={onConfirm}>{confirmButtonText}</Button>
            </Modal.Footer>
        </Modal>
    )
});

Confirm.displayName = 'Confirm';
