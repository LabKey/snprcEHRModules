import React from 'react'
import Select from 'react-select'
import moment from 'moment'
import WrappedDatePicker from '../../Shared/components/WrappedDatePicker'
import InfoPanel from '../../Shared/components/InfoPanel'
import { isBirthdateValid } from '../services/validation'

export default class DemographicsPanel extends React.Component {
    dateErrorMessageText = 'Birthdate must occur on or before the acquisition date.'

    state = {
        errorMessage: undefined
    }

    componentDidMount = () => {
      const { birthDate, acqDate } = this.props.newAnimalData
      const selectedOption = this.props.selectedOption
        this.setState(() => (
            {
                errorMessage: isBirthdateValid(birthDate.date, acqDate.date) ? undefined : this.dateErrorMessageText
            }
        ))
        this.props.preventNext()
        // if this.props.selectedOption = 'Acquisition' && isBirthdateValid(birthDate.date, acqDate.date) {
        //    load dams and sires with birthdate option
        //}

    }

    handleBdStatusChange = option => {
        this.props.handleDataChange('bdStatus', option)
    }

    handleDamChange = option => {
        this.props.handleDataChange('dam', option)
    }

    handleSireChange = option => {
        this.props.handleDataChange('sire', option)
    }

    handleGenderChange = option => {
        this.props.handleDataChange('gender', option)
    }

    handleBirthDateChange = date => {
        this.props.handleDataChange('birthDate', { date: moment(date) })
        this.setState(() => (
            {
                errorMessage: isBirthdateValid(moment(date), this.props.newAnimalData.acqDate.date) ? undefined : this.dateErrorMessageText
            }
        ))
    }

    handleBirthDateSelect = () => {
        // do nothing
    }

    render() {
        const { gender, dam, sire, birthDate, bdStatus } = this.props.newAnimalData
        const selectedOption = this.props.selectedOption
        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <WrappedDatePicker
                    dateFormat="Pp"
                    disabled={ this.props.disabled }
                    label="Birthdate"
                    maxDate={ moment().toDate() }
                    onChange={ this.handleBirthDateChange }
                    onSelect={ this.handleBirthDateChange }
                    selected={ birthDate.date.toDate() }
                    showTimeSelect
                    timeFormat="p"
                    timeIntervals={ 30 }
                    todayButton="Today"
                  />
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <label className="field-label">Birthdate Status</label>
                  <Select
                    autoFocus
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    defaultValue={ bdStatus }
                    id="bdStatus-select"
                    isClearable
                    isDisabled={ this.props.disabled }
                    isLoading={ this.props.bdStatusList.length === 0 }
                    onChange={ this.handleBdStatusChange }
                    options={ this.props.bdStatusList }
                    placeholder="Select Birthdate Status"
                  />
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <label className="field-label">Gender</label>
                  <Select
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    defaultValue={ gender }
                    id="gender-select"
                    isClearable
                    isDisabled={ this.props.disabled }
                    onChange={ this.handleGenderChange }
                    options={ [{ value: 'F', label: 'Female' },
                                    { value: 'M', label: 'Male' },
                                    { value: 'U', label: 'Unknown' }] }
                    placeholder="Select Gender"
                  />
                </div>
              </div>
              {this.props.potentialDamList.length > 0
                        && (
                        <div className="wizard-panel__row">
                          <div className="wizard-panel__col">
                            <label className="field-label">Dam</label>
                            <Select
                              className="shared-dropdown"
                              classNamePrefix="shared-select"
                              defaultValue={ dam }
                              id="dam-select"
                              isClearable
                              isDisabled={ this.props.disabled }
                              isLoading={ this.props.potentialDamList.length === 0 }
                              onChange={ this.handleDamChange }
                              options={ this.props.potentialDamList }
                              placeholder="Select Dam"
                            />
                          </div>
                        </div>
                        )}

              {this.props.potentialSireList.length > 0
                        && (
                        <div className="wizard-panel__row">
                          <div className="wizard-panel__col">
                            <label className="field-label">Sire</label>
                            <Select
                              className="shared-dropdown"
                              classNamePrefix="shared-select"
                              defaultValue={ sire }
                              id="sire-select"
                              isClearable
                              isDisabled={ this.props.disabled }
                              isLoading={ this.props.potentialSireList.length === 0 }
                              onChange={ this.handleSireChange }
                              options={ this.props.potentialSireList }
                              placeholder="Select Sire"
                            />
                          </div>
                        </div>
                        )}
            </div>
            <InfoPanel
              errorMessages={ this.state.errorMessage
                        && [{ propTest: true, colName: this.state.errorMessage }] }
              messages={
                        [{ propTest: !bdStatus, colName: 'Birthdate Status' },
                            { propTest: !gender, colName: 'Gender' }
                        ]
                    }
            />
          </>
        )
    }
}
