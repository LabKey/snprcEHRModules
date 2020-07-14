/* eslint max-classes-per-file: ["error", 2] */

import React from 'react'
import DatePicker from 'react-datepicker'

export default class WrappedDatePicker extends React.PureComponent {
    render() {
        return (
          <>
            { this.props.label && <label className="field-label">{this.props.label}</label> }
            <DatePicker
              customInput={ <DatePickerInput /> }
              dateFormat={ this.props.dateFormat }
              disabled={ this.props.disabled }
              disabledKeyboardNavigation={ this.props.disabledKeyboardNavigation }
              dropdownMode="select"
              id="date-picker"
              maxDate={ this.props.maxDate }
              onChange={ this.props.onChange }
              onChangeRaw={ this.props.onChangeRaw }
              onSelect={ this.props.onSelect }
              popperPlacement="bottom"
              readOnly={ this.props.readOnly }
              selected={ this.props.selected }
              showMonthDropdown
              showTimeSelect={ this.props.showTimeSelect }
              showYearDropdown
              timeFormat={ this.props.timeFormat }
              timeIntervals={ this.props.timeIntervals }
              todayButton={ this.props.todayButton }
            />
          </>
        )
    }
}

class DatePickerInput extends React.PureComponent {
    render() {
        return (
          <div className="datepicker-input-wrapper">
            <input
              className="datepicker-input"
              disabled={ this.props.disabled }
              onChange={ this.props.onChange }
              onClick={ this.props.onClick }
              type="text"
              value={ this.props.value }
            />
            <i aria-hidden="true" className="fa fa-calendar" onClick={ this.props.onClick } />
          </div>
        )
    }
}
