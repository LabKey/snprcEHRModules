import * as React from "react";
import {Button, Modal} from "react-bootstrap";



export default class Confirm extends React.PureComponent {

    render() {
        const { show, title, msg, onConfirm, onCancel, confirmButtonText, cancelButtonText, confirmVariant } = this.props;

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
    }
}