import React from 'react'
import Select from 'react-select'
import moment from 'moment'
import WrappedDatePicker from '../../Shared/components/WrappedDatePicker'
import InfoPanel from '../../Shared/components/InfoPanel'
import { validateNumAnimals, isFutureDate } from '../services/validation'
import constants from '../constants/index'

export default class AcquisitionPanel extends React.Component {
  dateErrorMessageText = 'Future dates are not allowed.'
  state = {
    errorMessage: undefined,
    infoMessage: undefined
  }
componentDidMount = () => {
    this.props.preventNext() // prevent/Allow Next button
  }
handleAcquisitionChange = option => {
    this.props.handleDataChange('acquisitionType', option)
  }
handleAcquisitionDateChange = date => {
  const acqDate = moment(date)
  const dateStatus = isFutureDate(acqDate) || this.props.debug // debug is triggered by test suite
    if (dateStatus) {
      this.props.handleDataChange('acqDate', { date: acqDate })
    }
    this.setState(() => ({
      errorMessage: dateStatus ? undefined : this.dateErrorMessageText
    }))
  }
handleSourceLocationChange = sourceLocation => {
    this.props.handleDataChange('sourceLocation', sourceLocation)
  }
handleNumAnimalChange = e => {
    const numAnimals = e.target.value

    const errorMessage = validateNumAnimals(numAnimals)
    if (errorMessage === undefined) {
      this.props.handleNumAnimalChange(numAnimals)
    }

    this.setState(prevState => (
      {
        ...prevState,
        errorMessage
      }
    ))
  }
isInteger = e => {
    const i = e.key // which ? e.which : e.keyCode;
    const isInteger = (i >= 0 && i <= 9)
    if (!isInteger) {
      e.preventDefault()
    }

    return isInteger
  }
handlePaste = e => {
    e.preventDefault()
  }
render() {
    const { acquisitionType, acqDate, species, sourceLocation, isNonPrimate } = this.props.newAnimalData
    const { numAnimals } = this.props
    const { selectedOption } = this.props

    return (
      <>
        <div className="wizard-panel__rows">
          <div className="wizard-panel__row">
            <div className="wizard-panel__col">
              <WrappedDatePicker
                dateFormat="Pp"
                disabled={ this.props.disabled }
                id="acquisition-datepicker"
                label="Acquisition Date"
                maxDate={ moment().toDate() }
                onChange={ this.handleAcquisitionDateChange }
                onSelect={ this.handleAcquisitionDateChange }
                selected={ acqDate.date.toDate() }
                showTimeSelect
                timeFormat="p"
                timeIntervals={ 30 }
                todayButton="Today"
              />
            </div>
          </div>
          <div className="wizard-panel__row">
            <div className="wizard-panel__col">
              <label className="field-label">Acquisition Code</label>
              <Select
                autoFocus
                className="shared-dropdown"
                classNamePrefix="shared-select"
                id="acquisition-select"
                isClearable
                isDisabled={ this.props.disabled }
                isLoading={ this.props.acquisitionTypeList.length === 0 }
                onChange={ this.handleAcquisitionChange }
                options={ this.props.acquisitionTypeList }
                placeholder="Select Acquisition Type"
                value={ acquisitionType || null }
              />
            </div>
            { selectedOption && selectedOption === 'Acquisition' && (
            <div className="wizard-panel__row">
              <div className="wizard-panel__col">
                <label className="field-label">Source Location</label>
                <Select
                  autoFocus
                  className="shared-dropdown"
                  classNamePrefix="shared-select"
                  id="location-select"
                  isClearable
                  isDisabled={ this.props.disabled }
                  isLoading={ this.props.sourceLocationList.length === 0 }
                  onChange={ this.handleSourceLocationChange }
                  options={ this.props.sourceLocationList }
                  placeholder="Select Source Location"
                  value={ sourceLocation || null }
                />
              </div>
            </div>
            )}
          </div>
          {species && isNonPrimate && (
            <div className="wizard-panel__row">
              <div className="wizard-panel__col">
                <label className="field-label">Number of Animals</label>

                <input
                  className="acq-input"
                  defaultValue={ numAnimals || 1 }
                  disabled={ this.props.disabled }
                  max="100"
                  min="1"
                  onChange={ this.handleNumAnimalChange }
                  onKeyPress={ this.isInteger }
                  onPasteCapture={ this.handlePaste }
                  type="number"
                />

              </div>
            </div>
          ) }
        </div>
        <InfoPanel
          errorMessages={ this.state.errorMessage && (
            [{ propTest: this.state.errorMessage, colName: this.state.errorMessage }]
          ) }
          infoMessages={ species && isNonPrimate && numAnimals && numAnimals !== 1 && [
            { key: 1, value: constants.hamsterWarnings }
          ] }
          messages={
            [{ propTest: !acquisitionType, colName: 'Acquisition Code' }]
          }
        />
      </>
    )
  }
}
