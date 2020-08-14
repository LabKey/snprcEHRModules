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
        console.log('CurrentAnimalPanel mounted')
    }

    logger = (args) => {
        let line = Array.prototype.slice.call(args).map(function (arg) {
            return typeof arg === 'string' ? arg : JSON.stringify(arg)
        }).join('')

        document.querySelector('#log').textContent += line + '\n'
    }

    onConnectClick = () => {

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

                    if (data && data.length > 0) {
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

        let chipData = this.props.chipData

        return (
            <>
                <div className="wizard-panel__rows">
                    <div className="wizard-panel__row">
                        <div className="wizard-panel__col">
                            <div>
                                <label className="field-label">Chip info</label>
                                <input
                                    className="cage-input"
                                    defaultValue={ chipData }
                                    disabled={ true }
                                    id="chip-input"
                                    onChange={ this.handleChange }
                                    placeholder="Chip data"
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="summary-panel__rows">
                    <div className="section-header">Serial Port</div>
                    <div className="summary-panel__row">
                        <div className="summary-panel__col">

                            <div id="output" >
                                <div id="content"></div>
                                <div id="status"></div>
                                <pre id="log"></pre>
                            </div>

                        </div>
                        <button onClick={ this.onConnectClick }>Connect to Reader</button>
                        <button onClick={ this.onQuitClick }>Quit</button>
                        <button onClick={ this.onStartClick }>Start</button>
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
