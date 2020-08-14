/* eslint-disable no-alert */

import React from 'react'
import { LoadingSpinner } from '@labkey/components'
import './styles/chipReader.scss'
import ChipReaderState from './constants/chipReaderState'
import constants from './constants/index'
import InfoPanel from '../Shared/components/InfoPanel'
import ChipDataPanel from './components/ChipDataPanel'
import SummaryGridPanel from './components/SummaryGridPanel'
import CancelChangeModal from './components/CancelChangeModal'

export default class ChipReader extends React.Component {
    state = new ChipReaderState();
    notSupportedMessage = constants.notSupportedMessage
    debug = constants.debug;
    isSerialSupported = ('serial' in navigator)


    componentDidMount() {
        // prevent user from navigating away from page
        window.addEventListener('beforeunload', this.beforeunload.bind(this))

        this.setState(prevState => (
            {
                ...prevState,
                serialOptions: constants.defaultSerialOptions,
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

    handleSetConnection = (connection) => {
        this.setState(prevState => (
            {
                ...prevState,
                connection
            }
        ))
    }

    handleDataChange = (value) => {
        this.setState( prevState => ({
            ...prevState,
            chipData: value
          })
        )
      };

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
                { this.isSerialSupported &&
                    <div className="split-panel">
                        <div className="parent-panel">
                            <div className="panel-heading" >
                                <p>Chip id</p>
                            </div>
                            <div className="wizard-panel" >
                                <ChipDataPanel
                                    handleSetConnection={this.handleSetConnection}
                                    handleDataChange= {this.handleDataChange}
                                    chipData= { this.state.chipData}
                                    serialOptions= {this.state.serialOptions}
                                    connection={ this.state.connection}
                                />
                            </div>

                        </div>

                        <div className="right-panel">
                            <div>
                                <div className="panel-heading">
                                    <p>Animals Seen</p>
                                </div>
                                <div className="wizard-right">
                                    <SummaryGridPanel
                                        summaryData={ this.state.summaryData }
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                }
                <InfoPanel
                    errorMessages={ !this.isSerialSupported
                        && [{ propTest: true, colName: this.notSupportedMessage }] }
                />
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
            </div >
        )
    }
}
