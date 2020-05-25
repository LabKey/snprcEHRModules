import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker'

export default class AcquisitionPanel extends React.Component {

    isLoading = true;

    componentDidMount = () => {
        this.props.debug ? this.props.preventNext(false) :
        this.props.preventNext(!this.props.newAnimalData.acquisitionType); //prevent/Allow Next button
    }

    handleAcquisitionChange = option => {
        this.props.handleDataChange('acquisitionType', option);
        this.props.preventNext(false); //allow Next button
    }
    handleAcquisitionDateChange = date => {
        this.props.handleDataChange('acqDate', { date });
    }

    render() {
        let { acquisitionType, acqDate } = this.props.newAnimalData;

        return (
            <>
                <div className="wizard-panel__rows" >
                    <div className="wizard-panel__row" >
                        <div className="wizard-panel__col">
                            <WrappedDatePicker
                                label="Acquisition Dates"
                                todayButton="Today"
                                showTimeSelect
                                timeFormat="p"
                                timeIntervals={30}
                                dateFormat="Pp"
                                maxDate={new Date()}
                                selected={acqDate.date}
                                onSelect={this.handleAcquisitionDateChange}
                                onChange={this.handleAcquisitionDateChange}
                                disabled={this.props.disabled}
                                id="acquisition-datepicker"
                            />
                            </div>
                    </div>
                    <div className='wizard-panel__row' >
                        <div className="wizard-panel__col">
                            <label className="field-label" >Acquisition Code</label>
                            <Select
                                defaultValue={acquisitionType}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                isLoading={this.props.acquisitionTypeList.length === 0}
                                options={this.props.acquisitionTypeList}
                                onChange={this.handleAcquisitionChange}
                                placeholder="Select Acquisition Type"
                                isDisabled={this.props.disabled}
                                id="acquisition-select"
                            />
                            </div>
                    </div>

                </div>
                {/* <div className="wizard-panel__row" > */}
                <div className="error-panel">
                    {!acquisitionType && 'Please select an Acquisition code.'}
                </div>
                {/* </div> */}
            </>
        )
    }
}
