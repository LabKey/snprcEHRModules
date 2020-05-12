import React from 'react';
import Select from 'react-select';
import DatePicker from 'react-datepicker';
import DatePickerInput from './DatePickerInput'
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';
import Label from 'react-bootstrap/lib/Label';


export default class LocationPanel extends React.Component {
    state = {
        selectedDate: this.props.acquisitionDate || new Date()
    }
    
    handleCageChange = (e) => {
        const option = e.target.value;
        this.props.handleCageChange(option);

        console.log(option);
    } 
    handleRoomChange = (room) => {
        const option = room;
        const el = document.getElementById("cage-input");
        if (room.maxCages) {
            el.disabled = false
            el.value = null;
            el.max = room.maxCages;
            this.props.handleCageChange(null);
        }
        else {
            el.disabled = true;
            el.value = null
            this.props.handleCageChange(null);
        }

        this.props.handleRoomChange(room);

        console.log(option);
    }

    handleDateSelect = date => {
        //do nothing
    };
    handleDateChangeRaw = (e) => {
        e.preventDefault();
      }
    render() {
        return (
            <div>
                <Row >
                    <Col  md={4} className="location-date">
                        <div className="location-datepicker">
                            <Label  className="label" >Move Date Time</Label>
                            <DatePicker
                                todayButton="Today"
                                showTimeSelect
                                timeFormat="HH:mm"
                                timeIntervals={30}
                                dateFormat="MM/dd/yy HH:mm"
                                maxDate={new Date()}
                                customInput={<DatePickerInput />}
                                selected={this.props.acquisitionDate}
                                onSelect={this.handleDateSelect}
                                onChange={this.handleDateSelect}
                                onChangeRaw={this.handleDateChangeRaw}
                                readOnly={true}
                                disabledKeyboardNavigation={true}
                            />
                        </div>
                    </Col>
                </Row>
                <Row >
                <Col md={4}  >
                    <Label  className="label" >Location</Label>
                    <Select 
                            className="location-dropdown"
                            classNamePrefix="location-select"
                            options={this.props.locationList}
                            onChange={this.handleRoomChange}
                            placeholder="Select Location"
                            isDisabled={false}
                    />
                </Col>
                <Col md={4} xsOffset={1} mdOffset={1}>
                    <Label  className="label" >Cage</Label>
                    <input type="number" id="cage-input"
                        className="cage-input"
                        placeholder="Cage #"
                        min="1"
                        onChange={this.handleCageChange}
                        disabled
                    />
                </Col>
            </Row>    

            </div>
            
        )
    }
}
