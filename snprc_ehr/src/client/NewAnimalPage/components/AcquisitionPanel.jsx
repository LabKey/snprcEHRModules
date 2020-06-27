import React from 'react'
import Select from 'react-select'
import moment from 'moment'
import WrappedDatePicker from './WrappedDatePicker'
import InfoPanel from './InfoPanel'

export default class AcquisitionPanel extends React.Component {
    componentDidMount = () => {
        this.props.preventNext() // prevent/Allow Next button
    }

    handleAcquisitionChange = option => {
        this.props.handleDataChange('acquisitionType', option)
    }

    handleAcquisitionDateChange = date => {
        this.props.handleDataChange('acqDate', { date: moment(date) })
    }

    render() {
        const { acquisitionType, acqDate } = this.props.newAnimalData

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

            </div>
            <InfoPanel
              messages={
                        [{ propTest: !acquisitionType, colName: 'Acquisition Code' }]
                    }
            />
          </>
        )
    }
}
