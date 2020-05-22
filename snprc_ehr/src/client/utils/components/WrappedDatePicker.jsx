import React from 'react';
import DatePicker from 'react-datepicker';

export default class WrappedDatePicker extends React.Component {
    render() {
      return (
            <>
                { this.props.label && <label className="field-label" >{this.props.label}</label> }
                <DatePicker
                    id="date-picker"
                    todayButton={this.props.todayButton}
                    showTimeSelect={this.props.showTimeSelect}
                    timeFormat={this.props.timeFormat}
                    timeIntervals={this.props.timeIntervals}
                    dateFormat={this.props.dateFormat}
                    maxDate={this.props.maxDate}
                    customInput={<DatePickerInput/>}
                    selected={this.props.selected}
                    onSelect={this.props.onSelect}
                    onChange={this.props.onChange}
                    onChangeRaw={this.props.onChangeRaw}
                    disabledKeyboardNavigation={this.props.disabledKeyboardNavigation}
                    readOnly={this.props.readOnly}
                    disabled={this.props.disabled}
                    popperPlacement="bottom"
                    showMonthDropdown
                    showYearDropdown
                    dropdownMode="select"
                />
            </>
      )
    }
}

class DatePickerInput extends React.Component {
    render() {
      return (
        <div className="datepicker-input-wrapper" >
          <input 
              onClick={this.props.onClick} 
              onChange={this.props.onChange}
              className="datepicker-input" 
              value={this.props.value} 
              type="text" 
              disabled={this.props.disabled}
            />
          <i onClick={this.props.onClick} aria-hidden="true" className="fa fa-calendar"></i>
        </div>
      )
    }
  }