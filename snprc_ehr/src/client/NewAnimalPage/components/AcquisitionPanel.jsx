import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker'

export default class AcquisitionPanel extends React.Component {

    handleAcquisitionChange = option => {
        this.props.handleDataChange('acquisitionType', option);
    }
    handleAcquisitionDateChange = date => {
        this.props.handleDataChange('acqDate', date);

    }
   
    render() {
        let { acquisitionType, acqDate } = this.props.newAnimalData;
        return (
            <>
                <div className="wizard-panel__rows">
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
                                selected={acqDate}
                                onSelect={this.handleAcquisitionDateChange}
                                onChange={this.handleAcquisitionDateChange}
                                disabled={this.props.disabled}
                                id="acquisition-datepicker"
                            />
                        </div>
                    </div>
                    <div className='wizard-panel__row' >
                        <div className='wizard-panel__col'>
                            <label className="field-label" >Acquisition Code</label>
                            <Select 
                                defaultValue={ acquisitionType }
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.acquisitionTypeList}
                                onChange={this.handleAcquisitionChange}
                                placeholder="Select Acquisition Type"
                                isDisabled={this.props.disabled}
                                id="acquisition-select"
                            />
                        </div>
                    </div>
                </div>
            </>
        )
    }
}
