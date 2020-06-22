import React from 'react';
import { Modal, Button } from 'react-bootstrap';
import SummaryPanel from './SummaryPanel';
import SuccessPanel from './SuccessPanel';

{/* Species Change Modal */ }

export class SaveModal extends React.PureComponent {

    render() {
        return (
            <Modal
                show={this.props.show}
                onHide={this.props.onCloseClick}
                dialogClassName="custom-modal"
            >
                <Modal.Header closeButton>
                    <Modal.Title>Okay to Save?</Modal.Title>
                </Modal.Header>

                <Modal.Body>
                    <SummaryPanel
                        newAnimalData={this.props.newAnimalData}
                        infoMessages={[{ key: 1, value: 'Please review data before saving.' },
                        { key: 2, value: 'Hover cursor over fields for full text.' }]}
                    />
                </Modal.Body>

                <Modal.Footer>
                    <Button onClick={this.props.onCloseClick} >Close</Button>
                    <Button bsStyle="primary" onClick={this.props.onSaveClick}>Save changes</Button>
                </Modal.Footer>
            </Modal>
        )
    }
}


export class CancelChangeModal extends React.PureComponent {

    render() {
        return (
            <Modal
                show={this.props.show}
                onHide={this.props.noClick}
                dialogClassName="center-modal"
            >
                <Modal.Header closeButton>
                    <Modal.Title>{this.props.title}</Modal.Title>
                </Modal.Header>

                <Modal.Body>
                    <p>{this.props.message}</p>
                </Modal.Body>

                <Modal.Footer>
                    <Button onClick={this.props.yesClick} >Yes</Button>
                    <Button bsStyle="primary" onClick={this.props.noClick}>No</Button>
                </Modal.Footer>
            </Modal>
        )
    }
}

export class SuccessModal extends React.PureComponent {

    render() {
        return (
            <Modal
                show={this.props.show}
                onHide={this.props.onCloseClick}
                dialogClassName="custom-modal"
            >
                <Modal.Header closeButton>
                    <Modal.Title>Save Was Successful!</Modal.Title>
                </Modal.Header>

                <Modal.Body>
                    <SuccessPanel
                        newAnimalData={this.props.newAnimalData}
                        infoMessages={[{ key: 1, value: 'Click Okay to continue.' }]}
                    />
                </Modal.Body>

                <Modal.Footer>
                    <Button onClick={this.props.okClick} >Okay</Button>
                </Modal.Footer>
            </Modal>
        )
    }
}
