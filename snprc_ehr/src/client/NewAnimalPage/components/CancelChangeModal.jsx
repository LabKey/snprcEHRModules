import React from 'react'
import { Modal, Button } from 'react-bootstrap'

export default class CancelChangeModal extends React.PureComponent {
    render() {
        return (
          <Modal
            dialogClassName="center-modal"
            onHide={ this.props.noClick }
            show={ this.props.show }
          >
            <Modal.Header closeButton>
              <Modal.Title>{this.props.title}</Modal.Title>
            </Modal.Header>

            <Modal.Body>
              <p>{this.props.message}</p>
            </Modal.Body>

            <Modal.Footer>
              <Button onClick={ this.props.yesClick }>Yes</Button>
              <Button bsStyle="primary" onClick={ this.props.noClick }>No</Button>
            </Modal.Footer>
          </Modal>
        )
    }
}
