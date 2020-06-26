import React from 'react'
import { Modal, Button } from 'react-bootstrap'
import SummaryPanel from './SummaryPanel'

export default class SaveModal extends React.PureComponent {
    state = {
        disabled: false
    }

    onExit = () => {
        this.setState(() => (
            { disabled: false }
        ))
    }

    onSaveClick = () => {
        this.setState(() => (
            { disabled: true }
        ), this.props.onSaveClick())
    };

    onCloseClick = () => {
        this.setState(() => (
            { disabled: true }
        ), this.props.onCloseClick())
    };

    render() {
        return (
          <Modal
            backdrop="static"
            dialogClassName="custom-modal"
            keyboard
            onExit={ this.onExit }
            onHide={ this.onCloseClick }
            show={ this.props.show }
          >
            <Modal.Header closeButton>
              <Modal.Title>Okay to Save?</Modal.Title>
            </Modal.Header>

            <Modal.Body>
              <SummaryPanel
                infoMessages={ [{ key: 1, value: 'Please review data before saving.' },
                            { key: 2, value: 'Hover cursor over fields for full text.' }] }
                newAnimalData={ this.props.newAnimalData }
              />
            </Modal.Body>

            <Modal.Footer>
              <Button disabled={ this.state.disabled } onClick={ this.onCloseClick }>Close</Button>
              <Button bsStyle="primary" disabled={ this.state.disabled } onClick={ this.onSaveClick }>Save changes</Button>
            </Modal.Footer>
          </Modal>
        )
    }
}
