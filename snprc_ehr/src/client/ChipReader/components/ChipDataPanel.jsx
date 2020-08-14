import React from 'react'
import InfoPanel from '../../Shared/components/InfoPanel'
import { requestPort, connect, close, read } from '../services/serialService'
import { getChipData } from '../services/microChipReader'

export default class ChipDataPanel extends React.Component {

    state = {
        errorMessage: undefined,
        isReading: false,
        connection: undefined
    }

    componentDidMount = () => {
        console.log('ChipDataPanel mounted')
    }

    onConnectClick = () => {
        if (!this.state.connection) {
            requestPort().then((serialPort) =>
                connect(serialPort, this.props.serialOptions).then((connection) => {
                    this.setState((prevState) => (
                        {
                            ...prevState,
                            errorMessage: undefined
                        }
                    ))
                    console.log(connection)
                    this.props.handleSetConnection(connection)
                })
            ).catch(error => {
                console.log(error.message)
                this.setState((prevState) => (
                    {
                        ...prevState,
                        errorMessage: error.message
                    }
                ))

            })
        }
    }
    
    yieldLoop = () => {
        return new Promise(resolve =>
            setImmediate(() => {
                resolve()
            })
        )
    }


    onStartClick = async () => {
        if (this.state.connection && !this.state.isReading) {
            this.setState((prevState) => (
                {
                    ...prevState,
                    isReading: true
                }
            ), async () => {
                this.props.handleDataChange(undefined)
                let data = undefined

                console.log('starting reader')

                // serial port read loop
                while (this.state.isReading) {
                    data = await getChipData(this.state.connection).catch(error => {
                        this.setState((prevState) => (
                            {
                                ...prevState,
                                errorMessage: error.message
                            }
                        ))
                    })

                    await this.yieldLoop() // interupt event loop 

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
            this.setState((prevState) => (  // shutdown reading before closing connection
                {
                    ...prevState,
                    isReading: false
                }
            ), () => {
                close(this.state.connection).then(() => {
                    this.props.handleSetConnection(undefined)
                }).catch(error => {
                    this.setState((prevState) => (
                        {
                            ...prevState,
                            errorMessage: error.message
                        }
                    ))

                })
            })
        }
    }

    handleChange = () => { /* lint fix */ }

    render() {
        this.state.connection = this.props.connection && this.props.connection

        let { chipId, animalId, temperature } = this.props.chipData && this.props.chipData

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
                                    disabled={ true }
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
                                    disabled={ true }
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
                                    disabled={ true }
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
                        <div className="summary-panel__col">
                            { // display reader state
                                (this.state.connection && !this.state.isReading && <div className='chip-info-span'> Reader connected - not reading  </div>)
                                || (this.state.isReading && <div className='chip-info-span'>  Reader connected - reading </div>)
                                || <div className='chip-info-span'> Reader not connected  </div>
                            }

                        </div>
                        <div className="button-row">
                            <button onClick={ this.onConnectClick }>Connect to Reader</button>
                            <button onClick={ this.onStartClick }>Start</button>
                            <button onClick={ this.onQuitClick }>Quit</button>
                        </div>
                    </div>
                </div>

                <InfoPanel
                    errorMessages={ this.state.errorMessage
                        && [{ propTest: true, colName: this.state.errorMessage }] }

                />
            </>
        )
    }
}
