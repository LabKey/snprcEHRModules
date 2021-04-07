import React from 'react'
import Select from 'react-select'
import WrappedDatePicker from '../../Shared/components/WrappedDatePicker'
import InfoPanel from '../../Shared/components/InfoPanel'
import { validateCage } from '../services/validation'

export default class LocationPanel extends React.Component {
    state = {
        errorMessage: undefined
    }
componentDidMount = () => {
        this.props.preventNext() // prevent/Allow Next button
    }
handleCageChange = e => {
        const cage = e.target.value
        const { room } = this.props.newAnimalData

        const errorMessage = validateCage(room, cage)
        if (errorMessage === undefined) {
            this.props.handleDataChange('cage', { value: cage })
        }

        this.setState(prevState => (
            {
                ...prevState,
                errorMessage
            }
        ))
    }
handleRoomChange = room => {
        const el = document.getElementById('cage-input')
        if (room.maxCages) {
            el.disabled = false
            el.value = null
            el.max = room.maxCages
        } else {
            el.disabled = true
            el.value = null
        }
        this.props.handleDataChange('room', room)
        this.props.handleDataChange('cage', { value: undefined })
    }
handleDateSelect = () => {
        // do nothing
    }
handleDateChangeRaw = e => {
        e.preventDefault()
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
        const { room, cage, acqDate } = this.props.newAnimalData
        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <div className="location-datepicker">
                    <WrappedDatePicker
                      dateFormat="Pp"
                      disabled={ this.props.disabled }
                      disabledKeyboardNavigation
                      label="Move Date Time"
                      onChange={ this.handleDateSelect }
                      onChangeRaw={ this.handleDateChangeRaw }
                      onSelect={ this.handleDateSelect }
                      readOnly
                      selected={ acqDate.date.toDate() }
                      todayButton="Today"
                    />
                  </div>
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <label className="field-label">Location</label>
                  <Select
                    autoFocus
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    defaultValue={ room }
                    id="location-select"
                    isDisabled={ this.props.disabled }
                    isLoading={ this.props.locationList.length === 0 }
                    onChange={ this.handleRoomChange }
                    options={ this.props.locationList }
                    placeholder="Select Location"
                  />
                </div>
              </div>
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <label className="field-label">Cage</label>
                  <input
                    className="cage-input"
                    defaultValue={ cage.value }
                    disabled={ !(room && room.maxCages) }
                    id="cage-input"
                    max={ room ? room.maxCages : 1 }
                    min="1"
                    onChange={ this.handleCageChange }
                    onKeyPress={ this.isInteger }
                    onPasteCapture={ this.handlePaste }
                    placeholder="Cage #"
                    type="number"
                  />
                </div>
              </div>
            </div>
            <InfoPanel
              errorMessages={ this.state.errorMessage && (
                        [{ propTest: this.state.errorMessage, colName: this.state.errorMessage }]
              ) }
              messages={
                        [{ propTest: !room, colName: 'Location' }]
                    }
            />
          </>
        )
    }
}
