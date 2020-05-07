import React from 'react';
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';
import Select from 'react-select';


export default class AcquisitionPanel extends React.Component {
    
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
                       
                    </Col>
                </Row>
            </span>
        )
    }
}
