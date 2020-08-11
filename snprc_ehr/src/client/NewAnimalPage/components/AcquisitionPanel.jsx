import React from 'react'
import Select from 'react-select'
import moment from 'moment'
import WrappedDatePicker from '../../Shared/components/WrappedDatePicker'
import InfoPanel from '../../Shared/components/InfoPanel'
import { validateNumAnimals } from '../services/validation'

export default class AcquisitionPanel extends React.Component {
  state = {
    errorMessage: undefined
  }

  componentDidMount = () => {
    this.props.preventNext() // prevent/Allow Next button
  }

  handleAcquisitionChange = option => {
    this.props.handleDataChange('acquisitionType', option)
  }

  handleAcquisitionDateChange = date => {
    this.props.handleDataChange('acqDate', { date: moment(date) })
  }

  handleNumAnimalChange = e => {
    const numAnimals = e.target.value

    const errorMessage = validateNumAnimals(numAnimals)
    if (errorMessage === undefined) {
      this.props.handleDataChange(numAnimals)
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
    console.log(i)
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
    const { acquisitionType, acqDate, species } = this.props.newAnimalData
    const numAnimals = this.props.numAnimals

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
          </div>
          { species && species.arcSpeciesCode === 'MA' && (
            <div className="wizard-panel__row">
              <div className="wizard-panel__col">
                <label className="field-label">Number of Animals</label>
                
                  <input
                    className="cage-input"
                    defaultValue={ numAnimals ? numAnimals : 1 }
                    onKeyPress={ this.isInteger }
                    onPasteCapture={ this.handlePaste }
                    type="text"
                    onChange={ this.handleNumAnimalChange }
                    max="100"
                    min="1"
                    type="number"
                  />
                
              </div>
            </div>
          ) }
        </div>
        <InfoPanel
          errorMessages={
            [{ propTest: this.state.errorMessage, colName: this.state.errorMessage }]
          }
          messages={
            [{ propTest: !acquisitionType, colName: 'Acquisition Code' }]
          }
        />
      </>
    )
  }
}
