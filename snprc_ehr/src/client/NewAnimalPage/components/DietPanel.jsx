import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker'

export default class DietPanel extends React.Component {

    handleDateSelect = date => {
        //do nothing
    };
    handleDateChangeRaw = e => {
        e.preventDefault();
    }
    handleDataChange = option => {
        const validatedOption = this.validate('diet', option);
        this.props.handleDataChange('diet', validatedOption);
    }
    validate = (property, option) => {
        return ( {
            ...option,
            hasError: false
        })
    }

    render() {
        let { diet, acqDate } = this.props.newAnimalData;
        return (
            <div className="wizard-panel__rows">
                <div className='wizard-panel__row' >
                    <div className='wizard-panel__col'>
                        <div className="diet-datepicker">
                            <WrappedDatePicker
                                label="Diet Date"
                                todayButton="Today"
                                dateFormat="Pp"
                                selected={acqDate.date}
                                onSelect={this.handleDateSelect}
                                onChange={this.handleDateSelect}
                                onChangeRaw={this.handleDateChangeRaw}
                                readOnly={true}
                                disabledKeyboardNavigation={true}
                                disabled={this.props.disabled}
                            />
                        </div>
                    </div>
                </div>
                <div className='wizard-panel__row' >
                    <div className='wizard-panel__col'>
                        <label className="field-label" >Diet</label>
                        <Select
                            defaultValue={ diet }
                            className="shared-dropdown"
                            classNamePrefix="shared-select"
                            options={this.props.dietList}
                            onChange={this.handleDataChange}
                            placeholder="Select diet"
                            isDisabled={this.props.disabled}
                            isLoading={this.props.dietList.length === 0}
                        />
                    </div>
                </div>
            </div>

        )
    }
}
