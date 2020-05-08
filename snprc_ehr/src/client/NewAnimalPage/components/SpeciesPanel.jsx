import React from 'react';
import InputGroup from 'react-bootstrap/InputGroup';
import Col from 'react-bootstrap/Col';
import Row from 'react-bootstrap/Row';
import Select from 'react-select';


export default class SpeciesPanel extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedOption: "option1",
            isDropup: false
        };


    }

    handleAcquisitionChange = (e) => {
        //e.preventDefault();
        const option = e.target.value;
        this.setState({ selectedOption: option })
        this.props.handleAcquisitionChange(option);

        console.log(option);
    }
    handleSpeciesChange = (value) => {

        const option = value;
        this.props.handleSpeciesChange(value);

        console.log(option);
    }

    render() {
        return (
            <span className="species-panel-wrapper">
                <Row>
                    <Col className="col-md-4">
                        <InputGroup size="lg">
                            <InputGroup.Prepend >
                                <InputGroup.Text > Birth </InputGroup.Text>
                                <InputGroup.Radio value='Birth'
                                    checked={this.state.selectedOption === 'Birth'}
                                    onChange={this.handleAcquisitionChange}
                                />
                                <InputGroup.Text > Other Acquisition </InputGroup.Text>
                                <InputGroup.Radio value='Other'
                                    checked={this.state.selectedOption === 'Other'}
                                    onChange={this.handleAcquisitionChange}
                                />
                            </InputGroup.Prepend>
                        </InputGroup>
                    </Col>
                    <Col className="col-md-8">
                        <Select
                            className="species-dropdown"
                            options={this.props.speciesMap}
                            onChange={this.handleSpeciesChange}
                            placeholder="Select Species"
                            isDisabled={false}
                        />
                    </Col>
                </Row>


            </span>
        )
    }
}
