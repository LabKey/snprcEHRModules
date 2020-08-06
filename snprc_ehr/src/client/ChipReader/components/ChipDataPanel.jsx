import React from 'react'
import Select from 'react-select'
import InfoPanel from '../../Shared/components/InfoPanel'
import { requestPort, connect } from '../services/serialService'

export default class ChipDataPanel extends React.Component {
    dateErrorMessageText = 'Birthdate must occur on or before the acquisition date.'

    state = {
        errorMessage: undefined
    }

    componentDidMount = () => {
        console.log('CurrentAnimalPanel mounted')
    }

    logger = (args) => {
        let line = Array.prototype.slice.call(args).map(function (arg) {
            return typeof arg === 'string' ? arg : JSON.stringify(arg);
        }).join('');

        document.querySelector('#log').textContent += line + '\n';
    }

    onButtonClick = () => {

        requestPort().then( (serialPort) => 
            connect(serialPort, 9600).then(( port ) => {
                console.log(port)
                this.props.handleSetPort(port)
            })
            
        )
    }
    render() {
        let { port }  = !this.props.port ? 'Not selected' : this.props.port

        return (
            <>
                <div className="wizard-panel__rows">
                    <div className="wizard-panel__row">
                        <div className="wizard-panel__col">
                            <div>
                                <p>Port: </p>
                            </div>
                            <p>Scanned chip goes here</p>
                        </div>
                    </div>
                </div>

                <div className="summary-panel__rows">
                    <div className="section-header"><h3>Serial Output</h3></div>
                    <div className="summary-panel__row">
                        <div className="summary-panel__col">

                            <div id="output" >
                                <div id="content"></div>
                                <div id="status"></div>
                                <pre id="log"></pre>
                            </div>

                        </div>
                        <button onClick={this.onButtonClick}>Connect to Reader</button>
                    </div>
                </div>

                    <InfoPanel
                        errorMessages={this.state.errorMessage
                            && [{ propTest: true, colName: this.state.errorMessage }]}

                    />
            </>
        )
    }
}
