import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker';

export default class DemographicsPanel extends React.Component {
    state = {
        selectedDate: this.props.newAnimalData.birthDate || new Date()
    }

    handleDamChange = option => {
        this.props.handleDataChange('dam', option);
    }
    handleSireChange = option => {
        this.props.handleDataChange('sire', option);
    }
    handleGenderChange = option => {
        this.props.handleDataChange('gender', option);
    }
    handleBirthDateChange = (date) => {
        this.handleDateSelect(date);
        this.props.handleDataChange('birthDate', date);
    }

    handleDateSelect = date => {
        this.setState({
            selectedDate: date
        });
    };


    render() {
        let {gender, dam, sire} = this.props.newAnimalData;
        return (
            <div className="wizard-panel__rows">
                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <WrappedDatePicker
                            label="Birthdate"
                            todayButton="Today"
                            showTimeSelect
                            timeFormat="p"
                            timeIntervals={30}
                            dateFormat="Pp"
                            maxDate={new Date()}
                            selected={this.state.selectedDate} 
                            onSelect={this.handleDateSelect}
                            onChange={this.handleBirthDateChange}
                            disabled={this.props.disabled}
                        />
                    </div>
                </div>
                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <label className="field-label" >Gender</label>
                        <Select
                            defaultValue={gender}
                            className="shared-dropdown"
                            classNamePrefix="shared-select"
                            options={[{ value: "F", label: "Female" },
                            { value: "M", label: "Male" },
                            { value: "U", label: "Unknown" }]}
                            onChange={this.handleGenderChange}
                            placeholder="Select Gender"
                            isDisabled={this.props.disabled}
                            id="gender-select"
                        />
                    </div>
                </div>

                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <label className="field-label" >Dam</label>
                        <Select
                            defaultValue={dam}
                            className="shared-dropdown"
                            classNamePrefix="shared-select"
                            options={this.props.potentialDamList}
                            onChange={this.handleDamChange}
                            placeholder="Select Dam"
                            isDisabled={this.props.disabled}
                            id="dam-select"
                        />
                    </div>
                </div>

                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <label className="field-label" >Owner</label>
                        <Select
                            defaultValue={sire}
                            className="shared-dropdown"
                            classNamePrefix="shared-select"
                            options={this.props.potentialSireList}
                            onChange={this.handleSireChange}
                            placeholder="Select Sire"
                            isDisabled={this.props.disabled}
                            id="sire-select"
                        />
                    </div>
                </div>
            </div>

        )
    }
}
