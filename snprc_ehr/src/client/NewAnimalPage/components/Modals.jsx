import React from 'react';
import { Modal, Button } from 'react-bootstrap';
import SummaryPanel from './SummaryPanel';

export class SaveModal extends React.PureComponent {
    state = {
        disabled: false
    }
    
    onExit = () => {
        this.setState( () => (
            { disabled: false}
        ));
    }
    onSaveClick = () => {
        this.setState( () => (
            { disabled: true}
        ), this.props.onSaveClick());
    };
    onCloseClick = () => {
        this.setState( () => (
            { disabled: true}
        ), this.props.onCloseClick());
    };

    render() {
        return (
            <Modal
                backdrop='static'
                onExit={this.onExit}
                onHide={this.onCloseClick}
                keyboard={true}
                show={this.props.show}
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
                    <Button onClick={this.onCloseClick} disabled={this.state.disabled}>Close</Button>
                    <Button bsStyle="primary" onClick={this.onSaveClick} disabled={this.state.disabled} >Save changes</Button>
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
