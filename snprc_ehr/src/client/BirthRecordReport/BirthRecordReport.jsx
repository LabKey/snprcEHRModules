/* eslint-disable no-alert */

import React from 'react'
import { LoadingSpinner } from '@labkey/components'
import './styles/birthRecordReport.scss'
import { Button } from 'react-bootstrap'
import BirthRecordState from './constants/BirthRecordState'
import AnimalSelectionPanel from './components/AnimalSelectionPanel'
import fetchNewAnimalData from './api/fetchNewAnimalData'
import SummaryGridPanel from './components/SummaryGridPanel'
import { getReportPath } from './services/printToPDF'
import InfoPanel from '../Shared/components/InfoPanel'

export default class BirthRecordReport extends React.Component {
    state = new BirthRecordState();

    componentDidMount() {
        Promise.resolve(this.loadLists()).catch = error => {
            console.log(`Error in componentDidMount: ${error}`)
        }
    }

    loadLists() {
        let animalList = []

        return new Promise(() => {
            (
                fetchNewAnimalData().then(list => {
                    animalList = list
                })
            ).then(() => {
                this.setState(prevState => (
                    {
                        ...prevState,
                        isLoading: false,
                        animalList
                    }
                ))
            }).catch(error => {
                console.log(`Error in loadLists: ${error}`)
            })
        })
    }

    // quit
    onQuitClick = () => {
        window.history.back()
    }

    onClickPrint = () => {
        if (!this.state.selectedAnimal) {
            this.setState(prevState => (
                {
                    ...prevState,
                    errorMessage: 'Select an animal before clicking print.'
                }))
        } else {
            const reportPath = getReportPath('BirthRecord')
            const fullPath = `${reportPath}&rc:Parameters=Collapsed&TargetID=${this.state.selectedAnimal.Id}`
            const left = window.screenX + 20

            window.open(fullPath, '_blank', `location=yes,height=850,width=768,status=yes, left=${left}`)

            // add animal to the summary list if it is not there
            if (!this.state.summaryData.find(o => o.Id === this.state.selectedAnimal.Id)) {
                this.setState(prevState => (
                    {
                        ...prevState,
                        summaryData: [
                            ...prevState.summaryData,
                            { ...prevState.selectedAnimal }
                        ]
                    }))
            }
        }
    }

    handleChange = option => {
        this.setState(prevState => (
            {
                ...prevState,
                errorMessage: undefined,
                selectedAnimal: option
            }
        ))
    }

    render() {
        const { isLoading } = this.state

        if (isLoading) {
            return (
              <LoadingSpinner msg="Loading app..." />
            )
        }

        return (
          <div>
            <div className="split-panel">
              <div className="parent-panel">
                <div className="panel-heading">
                  <p>Select Animal</p>
                </div>
                <div className="wizard-panel">
                  <AnimalSelectionPanel
                    animalList={ this.state.animalList }
                    handleChange={ this.handleChange }
                    selectedAnimal={ this.state.selectedAnimal }
                  />
                  <InfoPanel
                    errorMessages={ this.state.errorMessage
                                && [{ propTest: true, colName: this.state.errorMessage }] }
                    infoMessages={ [{ key: 1, value: 'Select an animal and press the print button to generate the Birth Record Report.' }] }
                  />
                </div>
              </div>
              <div className="right-panel">
                <div className="panel-heading">
                  <p>Reports Printed</p>
                </div>
                <div className="wizard-right">
                  <SummaryGridPanel
                    summaryData={ this.state.summaryData }
                  />
                </div>
              </div>
            </div>

            <div className="wizard-footer">
              <Button bsStyle="primary" onClick={ this.onClickPrint }>Print Birth Record <i aria-hidden="true" className="fa fa-print" /></Button>
              <Button onClick={ this.onQuitClick }>Quit</Button>
            </div>
          </div>
        )
    }
}
