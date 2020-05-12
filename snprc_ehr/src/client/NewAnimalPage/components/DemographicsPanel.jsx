import React from 'react';
import Select from 'react-select';
import DatePicker from 'react-datepicker';
import DatePickerInput from './DatePickerInput'
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';
import Label from 'react-bootstrap/lib/Label';


export default class DemographicsPanel extends React.Component {
    state = {
        selectedDate: this.props.birthDate || new Date(),
        selectedDam: undefined,
        selectedSire: undefined,
        selectedGender: undefined
    }
    
    handlePotentialDamChange = (value) => {
        this.props.handlePotentialDamChange(value);
    }

    handlePotentialSireChange = (value) => {
        this.props.handlePotentialSireChange(value);
    }
    handleGenderChange = (value) => {
        const option = value;
        this.props.handleGenderChange(value);

        console.log(option);
    }
    handleBirthDateChange = (date) => {
        this.props.handleBirthDateChange(date);
    }

    handleDateSelect = date => {
        this.setState({
            selectedDate: date
        });
    };

    
    render() {
        const resultLimit = 10
        let i = 0
        return (
            <div>
                <Row >
                
                    <Col md={5} className="birthdate">
                        <Label  className="label" >Birthdate</Label>
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
                                onChange={this.handleBirthDateChange}
                            />
                    </Col>
                </Row>
                <Row >
                    <Col md={8} >
                        <Label>Gender </Label>
                        <Select
                                className="demographics-dropdown"
                                classNamePrefix="demographics-select"
                                options={[{value: "F", label: "Female"}, 
                                    {value: "M", label: "Male"}, 
                                    {value: "U", label: "Unknown"}]}
                                onChange={this.handleGenderChange}
                                placeholder="Select Gender"
                                isDisabled={false}
                        />
                    </Col>
                </Row>
                <Row >
                    <Col md={4} >
                        <Label>Dam </Label>
                        <Select 
                                className="demographics-dropdown"
                                options={this.props.potentialDamList}
                                onChange={this.handlePotentialDamChange}
                                placeholder="Select Dam"
                                isDisabled={false}
                                filterOption={( {label}, query) => label.indexOf(query) >= 0 && i++ < resultLimit}
                                onInputChange={() => { i = 0 }}
                        />
                    </Col>
                </Row>
                <Row >
                    <Col md={4} >
                        <Label>Sire </Label>
                        <Select 
                                className="demographics-dropdown"
                                options={this.props.potentialSireList}
                                onChange={this.handlePotentialSireChange}
                                placeholder="Select Sire"
                                isDisabled={false}
                        />
                    </Col>
                </Row>
            </div>
            
        )
    }
}
