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
import fetchAnimalId from './api/fetchAnimalId'

export default class ChipReader extends React.Component {
    state = new ChipReaderState();
    notSupportedMessage = constants.notSupportedMessage
    debug = constants.debug;
    isSerialSupported = ('serial' in navigator)
    prevId = undefined


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

    handleDataChange = async (value) => {
        const data = value ? value : { chipId: undefined, animalId: undefined, temperature: undefined }

        if (!data.chipId || data.chipId === this.prevId)
            return

        console.log(`chipId = ${data.chipId}`)
        this.prevId = data.chipId

        if (data.chipId && !data.animalId) {
            data.animalId = await fetchAnimalId(data.chipId).catch(error => {
                this.setState((prevState) => (
                    {
                        ...prevState,
                        errorMessage: error.message
                    }
                ))

            })
        }

        this.setState( prevState => ({
            ...prevState,
            chipData: data,
            ...(data.animalId && { errorMessage: undefined }), // clear error message
            ...(data.animalId && {
                summaryData: [
                    ...prevState.summaryData,
                    { ...data }
                ]
            })
        }))
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
                                <p>Current Animal</p>
                            </div>
                            <div className="wizard-panel" >
                                <ChipDataPanel
                                    handleSetConnection={ this.handleSetConnection }
                                    handleDataChange={ this.handleDataChange }
                                    chipData={ this.state.chipData }
                                    serialOptions={ this.state.serialOptions }
                                    connection={ this.state.connection }
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
                    errorMessages={ (!this.isSerialSupported
                        && [{ propTest: true, colName: this.notSupportedMessage }])
                        || (this.state.errorMessage && [{ propTest: true, colName: this.state.errorMessage }])
                    }
                />
            </div >
        )
    }
}
