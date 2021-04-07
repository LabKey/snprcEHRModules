/* eslint-disable */

import React from 'react'
import { LoadingSpinner } from '@labkey/components'
import './styles/sndEventsViewer.scss'
import SndEventState from './constants/sndEventsState'
import constants from './constants/index'
import CancelChangeModal from './components/CancelChangeModal'
import SndEventsPanel from './components/SndEventsPanel'

export default class SndEventsViewer extends React.Component {
    state = new SndEventState();
debug = constants.debug;
componentDidMount() {
        // prevent user from navigating away from page
        window.addEventListener('beforeunload', this.beforeunload.bind(this))
        this.setState(prevState => (
            {
                ...prevState,
                isLoading: false
            }
        ))
    }
componentWillUnmount() {
        window.removeEventListener('beforeunload', this.beforeunload.bind(this))
    }
beforeunload(e) {
        if (this.state.isDirty) {
            e.preventDefault()
            e.returnValue = true
        }
    }
handleError = value => {
        this.setState(prevState => (
            {
                ...prevState,
                hasError: value
            }
        ))
    }
// Cancel button callback
    handleCancel = () => {
        if (this.state.isDirty) {
            this.setState(prevState => (
                {
                    ...prevState,
                    showCancelModal: true
                }
            ))
        } else {
            window.history.back()
        }
    }
// reset app
    onCancelClick = () => {
        this.setState(prevState => (
            {
                ...prevState,
                isDirty: false,
                showCancelModal: false
            }
        ))
        window.history.back()
    }
// dismiss modals
    onCloseClick = () => {
        this.setState(prevState => (
            {
                ...prevState,
                showCancelModal: false,
                showSaveModal: false,
                showSpeciesChangeModal: false
            }
        ))
    }
render() {
        // allow debug mode to be triggered for running test suite
        this.debug = this.props.debug !== undefined ? this.props.debug : constants.debug

        const { isLoading } = this.state

        if (isLoading) {
            return (
              <LoadingSpinner msg="Loading app..." />
            )
        }

        return (
          <div>
            <div className="parent-panel">
              <SndEventsPanel />
            </div>
            <div>
              {/* Cancel Modal */ }
              <CancelChangeModal
                message="If you cancel now, you will lose unsaved changes. Are you sure you want to cancel?"
                noClick={ this.onCloseClick }
                show={ this.state.showCancelModal }
                title="Quit?"
                yesClick={ this.onCancelClick }
              />
            </div>
          </div>
        )
    }
}
