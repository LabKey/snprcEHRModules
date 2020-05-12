import React from 'react';
import Select from 'react-select';
import DatePicker from 'react-datepicker';
import DatePickerInput from './DatePickerInput'
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';
import Label from 'react-bootstrap/lib/Label';


export default class AcquisitionPanel extends React.Component {
    state = {
        selectedDate: this.props.acquisitionDate || new Date()
    }
    
    handleAcquisitionChange = (value) => {

        const option = value;
        this.props.handleAcquisitionChange(value);

        console.log(option);
    }

    handleAcquisitionDateChange = (date) => {
        this.props.handleAcquisitionDateChange(date);
    }

    handleDateSelect = date => {
        this.setState({
            selectedDate: date
        });
    };
    
    render() {
        return (
            <Row className="show-grid">
                    <Col md={3} className="acquisition-date" >
                    <Label  className="label" >Acauisition Date</Label>
                            <DatePicker
                                todayButton="Today"
                                showTimeSelect
                                timeFormat="HH:mm"
                                timeIntervals={30}
                                dateFormat="MM/dd/yy hh:mm"
                                maxDate={new Date()}
                                customInput={<DatePickerInput />}
                                selected={this.state.selectedDate}
                                onSelect={this.handleDateSelect}
                                onChange={this.handleAcquisitionDateChange}
                            />
                    </Col>
                    <Col md={4} mdOffset={1} >
                        <Label  className="label" >Acauisition Code</Label>
                        <Select 
                                className="acquisition-dropdown"
                                classNamePrefix="acquisition-select"
                                options={this.props.acquisitionTypeList}
                                onChange={this.handleAcquisitionChange}
                                placeholder="Select Acquisition Type"
                                isDisabled={false}
                        />
                    </Col>
                </Row>
        )
    }
}
