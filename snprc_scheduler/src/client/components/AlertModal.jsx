import * as React from "react";
import {Button, Modal} from "react-bootstrap";



export default class AlertModal extends React.PureComponent {

    render() {
        const { show, title, msg, onDismiss } = this.props;

        return (
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
        )
    }
}