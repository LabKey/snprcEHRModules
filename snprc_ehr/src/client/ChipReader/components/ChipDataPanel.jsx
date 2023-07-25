/* eslint-disable no-await-in-loop */

import React from 'react'
import { requestPort, connect, close } from '../services/serialService'
import { getChipData } from '../services/microChipReader'
import constants from '../constants/index'

export default class ChipDataPanel extends React.Component {
    state = {
        isReading: false,
        connection: undefined
    }
componentDidMount = () => {
        console.log('ChipDataPanel mounted')
    }
onConnectClick = () => {
        if (!this.state.connection) {
            requestPort().then(serialPort => connect(serialPort, this.props.serialOptions).then(connection => {
                this.props.handleErrorMessage(undefined)
                this.props.handleSetConnection(connection)
            })).catch(error => {
                this.props.handleErrorMessage(error.message)
            })
        }
    }
flushPromises = () => { return new Promise(resolve => setTimeout(resolve)) }
onStartClick = async () => {
        if (this.state.connection && !this.state.isReading) {
            this.setState(prevState => (
                {
                    ...prevState,
                    isReading: true
                }
            ), async () => {
                this.props.handleDataChange(undefined)
                // let data

                console.log('starting reader')

                // serial port read loop
                while (this.state.isReading) {
                    const data = await getChipData(this.state.connection)
                        .then(results => {
                            // clear error message
                            if ((this.props.errorMessage && results && results.animalId)
                                || this.props.errorMessage === constants.timeOutErrorMessage) {
                                this.props.handleErrorMessage(undefined)
                            }
                            return results
                        })

                        .catch(error => {
                            this.props.handleErrorMessage(error.message)
                        })

                    await this.flushPromises() // interupt event loop

                    if (data && data.chipId.length > 0) {
                        this.props.handleDataChange(data)
                    }
                }
            })
        }
    }
onQuitClick = () => {
        // close serial connection
        if (this.state.connection) {
            this.setState(prevState => ( // shutdown reading before closing connection
                {
                    ...prevState,
                    isReading: false
                }
            ), () => {
                close(this.state.connection).then(() => {
                    this.props.handleSetConnection(undefined)
                }).catch(error => {
                    this.props.handleErrorMessage(error.message)
                })
            })
        }
    }
handleChange = () => { /* lint fix */ }
render() {
        this.state.connection = this.props.connection // && this.props.connection

        const { chipId, animalId, temperature } = this.props.chipData // && this.props.chipData

        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <div>
                    <label className="field-label">Chip ID</label>
                    <input
                      className="cage-input"
                      defaultValue={ chipId }
                      disabled
                      id="chip-chipId"
                      onChange={ this.handleChange }
                      placeholder="Chip ID"
                    />
                  </div>
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <div>
                    <label className="field-label">Animal ID</label>
                    <input
                      className="cage-input"
                      defaultValue={ animalId && animalId.value }
                      disabled
                      id="chip-animalId"
                      onChange={ this.handleChange }
                      placeholder="Animal ID"
                    />
                  </div>
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <div>
                    <label className="field-label">Temperature</label>
                    <input
                      className="cage-input"
                      defaultValue={ temperature }
                      disabled
                      id="chip-temperature"
                      onChange={ this.handleChange }
                      placeholder="Temperature"
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="summary-panel__rows">

              <div className="summary-panel__row">

                { // display reader state
                            (this.state.connection && !this.state.isReading && <div className="chip-info-span"> Reader connected - not reading  </div>)
                            || (this.state.isReading && <div className="chip-info-span">  Reader connected - reading </div>)
                            || <div className="chip-info-span"> Reader disconnected  </div>
                        }

                <div className="button-row">
                  <button id="connect" onClick={ this.onConnectClick } type="button">Connect to Reader</button>
                  <button id="start" onClick={ this.onStartClick } type="button">Start</button>
                  <button id="stop" onClick={ this.onQuitClick } type="button">Stop</button>
                </div>
              </div>
            </div>

          </>
        )
    }
}
