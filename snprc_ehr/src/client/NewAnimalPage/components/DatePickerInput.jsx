import React from 'react'

export default class DatePickerInput extends React.Component {
    render() {
      return (
        <div className="datepicker-input-wrapper">
          <input 
            onClick={this.props.onClick} 
            onChange={this.props.onChange}
            className="datepicker-input" 
            value={this.props.value} 
            type="text" />
          <i onClick={this.props.onClick} aria-hidden="true" className="fa fa-calendar"></i>
        </div>
      )
    }
  }