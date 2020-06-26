import React from 'react'
import Select from 'react-select'
import WrappedDatePicker from './WrappedDatePicker'
import InfoPanel from './InfoPanel'

export default class DietPanel extends React.Component {
    componentDidMount = () => {
        this.props.preventNext() // prevent/Allow Next button
    }

    handleDateSelect = () => {
        // do nothing
    };

    handleDateChangeRaw = e => {
        e.preventDefault()
    }

    handleDataChange = option => {
        this.props.handleDataChange('diet', option)
    }

    render() {
        const { diet, acqDate } = this.props.newAnimalData
        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <div className="diet-datepicker">
                    <WrappedDatePicker
                      dateFormat="Pp"
                      disabled={ this.props.disabled }
                      disabledKeyboardNavigation
                      label="Diet Date"
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
                  <label className="field-label">Diet</label>
                  <Select
                    autoFocus
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    defaultValue={ diet }
                    isClearable
                    isDisabled={ this.props.disabled }
                    isLoading={ this.props.dietList.length === 0 }
                    onChange={ this.handleDataChange }
                    options={ this.props.dietList }
                    placeholder="Select diet"
                  />
                </div>
              </div>
            </div>
            <InfoPanel
              messages={ [{ propTest: !diet, colName: 'Diet' }] }
            />
          </>
        )
    }
}
