import React from 'react';
import Select from 'react-select';
import moment from 'moment';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker';
import InfoPanel from './InfoPanel';
import { isBirthdateValid} from '../services/validation';

export default class DemographicsPanel extends React.Component {
    dateErrorMessageText = 'Birthdate must occur on or before the acquisition date.'

    state = {
        errorMessage: undefined
    }
    componentDidMount = () => {
        this.setState( () => (
            {
                errorMessage: isBirthdateValid(this.props.newAnimalData.birthDate.date, this.props.newAnimalData.acqDate.date) ? undefined : this.dateErrorMessageText
            }
        ));
        this.props.preventNext();
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
        this.props.handleDataChange('birthDate', { date: moment(date) });
        this.setState( () => (
            {
                errorMessage: isBirthdateValid(moment(date), this.props.newAnimalData.acqDate.date) ? undefined : this.dateErrorMessageText
            }
        ));
    }
    handleBirthDateSelect = (date) => {
        // do nothing
    }

    render() {
        let { gender, dam, sire, birthDate } = this.props.newAnimalData;
        return (
            <>
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
                                maxDate={moment().toDate()}
                                selected={birthDate.date.toDate()}
                                onSelect={this.handleBirthDateSelect}
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
                                isClearable={true}
                                id="gender-select"
                                autoFocus
                            />
                        </div>
                    </div>
                    {this.props.potentialDamList.length > 0 &&
                        <div className="wizard-panel__row" >
                            <div className="wizard-panel__col">
                                <label className="field-label" >Dam</label>
                                <Select
                                    defaultValue={dam}
                                    className="shared-dropdown"
                                    classNamePrefix="shared-select"
                                    isLoading={this.props.potentialDamList.length === 0}
                                    options={this.props.potentialDamList}
                                    onChange={this.handleDamChange}
                                    placeholder="Select Dam"
                                    isDisabled={this.props.disabled}
                                    isClearable={true}
                                    id="dam-select"
                                />
                            </div>
                        </div>
                    }

                    {this.props.potentialSireList.length > 0 &&
                        <div className="wizard-panel__row" >
                            <div className="wizard-panel__col">
                                <label className="field-label" >Sire</label>
                                <Select
                                    defaultValue={sire}
                                    className="shared-dropdown"
                                    classNamePrefix="shared-select"
                                    isLoading={this.props.potentialSireList.length === 0}
                                    options={this.props.potentialSireList}
                                    onChange={this.handleSireChange}
                                    placeholder="Select Sire"
                                    isDisabled={this.props.disabled}
                                    isClearable={true}
                                    id="sire-select"
                                />
                            </div>
                        </div>
                    }
                </div>
                <InfoPanel 
                    messages={ 
                        [ {propTest: !gender, colName: "Gender"} ]
                    }
                    errorMessages= { this.state.errorMessage &&
                        [ {propTest: true, colName: this.state.errorMessage} ]
                    }
                />
            </>
        )
    }
}
