import React from 'react';
import Select from 'react-select';
import moment from 'moment';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker';
import InfoPanel from './InfoPanel';

export default class DietPanel extends React.Component {
    componentDidMount = () => {
        this.props.preventNext(); //prevent/Allow Next button
    }
    handleDateSelect = date => {
        //do nothing
    };
    handleDateChangeRaw = e => {
        e.preventDefault();
    }
    handleDataChange = option => {
        this.props.handleDataChange('diet', option);
    }
    render() {
        let { diet, acqDate } = this.props.newAnimalData;
        return (
            <>
                <div className="wizard-panel__rows">
                    <div className='wizard-panel__row' >
                        <div className='wizard-panel__col'>
                            <div className="diet-datepicker">
                                <WrappedDatePicker
                                    label="Diet Date"
                                    todayButton="Today"
                                    dateFormat="Pp"
                                    selected={acqDate.date.toDate()}
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
                                defaultValue={diet}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.dietList}
                                onChange={this.handleDataChange}
                                placeholder="Select diet"
                                isDisabled={this.props.disabled}
                                isClearable={true}
                                isLoading={this.props.dietList.length === 0}
                                autoFocus
                            />
                        </div>
                    </div>
                </div>
                <InfoPanel
                    messages={[{ propTest: !diet, colName: 'Diet' }]}
                />
            </>
        )
    }
}
