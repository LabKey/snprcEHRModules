import React from 'react';
import { OverlayTrigger } from 'react-bootstrap';
import SummaryPopover from './SummaryPopover';
import InfoPanel from './InfoPanel';
import moment from 'moment';

export default class SuccessPanel extends React.Component {

    handleKeyPress = e => {
        e.preventDefault();
    }
    handlePaste = e => {
        e.preventDefault();
    }
    render() {

        let { id, acqDate, species } = this.props.newAnimalData;

        return (
            <>
                <div className="summary-panel__rows">
                    <div className='wizard-panel__row' >
                        <div className='wizard-panel__col '>
                            <label className="field-label-align-success" >Animal ID</label>
                            <OverlayTrigger overlay={<SummaryPopover message={id}
                                title="Animal Id" />} >
                                <input type="text"
                                    className="summary-text-input"
                                    defaultValue={id}
                                    onKeyPress={this.handleKeyPress}
                                    onPasteCapture={this.handlePaste}
                                />
                            </OverlayTrigger>
                        </div>
                        </div>
                        
                    <div className='wizard-panel__row' >
                        <div className='wizard-panel__col '>
                            <label className="field-label-align-success" >Acquisition Date</label>
                            <OverlayTrigger overlay={<SummaryPopover message={acqDate && moment(acqDate.date).format("MM/DD/YYYY h:mm A")}
                                title="Acquisition Date" />} >
                                <input type="text"
                                    className="summary-date-input"
                                    defaultValue={acqDate && moment(acqDate.date).format("MM/DD/YYYY h:mm A")}
                                    onKeyPress={this.handleKeyPress}
                                    onPasteCapture={this.handlePaste}
                                    style={{ width: '15rem' }}
                                />
                            </OverlayTrigger>
                        </div>
                        </div>
                        
                    <div className='wizard-panel__row' >
                        <div className='wizard-panel__col ' >
                            <label className="field-label-align-success">Species</label>
                            <OverlayTrigger overlay={<SummaryPopover message={species && species.label} title="Species" />} >
                                <input
                                    className="summary-text-input"
                                    defaultValue={species && species.label}
                                    onKeyPress={this.handleKeyPress}
                                    onPasteCapture={this.handlePaste}
                                />
                            </OverlayTrigger>
                        </div>
                    </div>
                    <InfoPanel
                        infoMessages={this.props.infoMessages}
                    />
                </div>
            </>
        )
    }
}
