import React from 'react';
import Select from 'react-select';
import DatePicker from 'react-datepicker';
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';

export default class AcquisitionPanel extends React.Component {
    state = {
        selectedDate: this.props.AcquisitionDate
    }
    
    handleAcquisitionChange = (e) => {
        //e.preventDefault();
        const option = e.target.value;
        this.setState({selectedOption: option})
        this.props.handleAcquisitionChange(option);

        console.log(option);
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
            <span >
                <Row >
                    <Col className="col-md-4">
                        <Select
                                    className="species-dropdown"
                                    options={this.props.acquisitionTypeList}
                                    onChange={this.handleAcquisitionChange}
                                    placeholder="Select Acquisition Type"
                                    isDisabled={false}
                            />
                    </Col>
                    <Col className="col-md-8">
                        <div >
                        <label className="datepicker-label">  
                            <DatePicker
                                todayButton="Today"
                                showTimeSelect
                                timeFormat="HH:mm"
                                timeIntervals={30}
                                dateFormat="MM/dd/yy hh:mm"
                                maxDate={new Date()}
                                selected={this.state.selectedDate}
                                onSelect={this.handleDateSelect}
                                onChange={this.handleAcquisitionDateChange}
                            />
                            <i className="fa fa-calendar datepicker-icon" ></i>
                        </label>
                        </div>
                    </Col>
                </Row>
            </span>
        )
    }
}
