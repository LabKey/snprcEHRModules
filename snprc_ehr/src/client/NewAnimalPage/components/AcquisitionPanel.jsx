import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker'
import InfoPanel from './InfoPanel';
import moment from 'moment';

export default class AcquisitionPanel extends React.Component {

    isLoading = true;

    componentDidMount = () => {
        this.props.preventNext(); //prevent/Allow Next button
    }

    handleAcquisitionChange = option => {
        this.props.handleDataChange('acquisitionType', option);
    }
    handleAcquisitionDateChange = date => {
        this.props.handleDataChange('acqDate', { date: moment(date) });
    }

    render() {
        let { acquisitionType, acqDate } = this.props.newAnimalData;

        return (
            <>
                <div className="wizard-panel__rows" >
                    <div className="wizard-panel__row" >
                        <div className="wizard-panel__col">
                            <WrappedDatePicker
                                label="Acquisition Date"
                                todayButton="Today"
                                showTimeSelect
                                timeFormat="p"
                                timeIntervals={30}
                                dateFormat="Pp"
                                maxDate={new Date()}
                                selected={acqDate.date.toDate()}
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
                                isClearable={true}
                                id="acquisition-select"
                                autoFocus
                            />
                        </div>
                    </div>

                </div>
                <InfoPanel 
                    messages={ 
                        [ {propTest: !acquisitionType, colName: "Acquisition Code"} ]
                    }
                        
                    />
            </>
        )
    }
}
