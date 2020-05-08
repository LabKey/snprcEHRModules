import React from 'react';
import FormGroup from 'react-bootstrap/lib/FormGroup';
import Col from 'react-bootstrap/lib/Col';
import Row from 'react-bootstrap/lib/Row';
import Radio from 'react-bootstrap/lib/Radio';
import Select from 'react-select';


export default class SpeciesPanel extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedOption: "option1",
            isDropup: false
        };
    }

    handleAcquisitionOptionChange = (e) => {
        //e.preventDefault();
        const option = e.target.value;
        this.setState({selectedOption: option})
        this.props.handleAcquisitionOptionChange(option);
        this.props.handleLoadAcuisitionTypes(option);

        console.log(option);
    }
    handleSpeciesChange = (value) => {

        const option = value;
        this.props.handleSpeciesChange(value);

        console.log(option);
    }
    filterTypes(types, category) {
        console.log('acquisition types')
        types.map((type) => {
            if (type.Category === category) {
                return type;
            }
        })
    }
    render() {
        return (
            <span >
                <Row >
                    <Col className="col-md-4">
                        <FormGroup>
                            <Radio inline className='species-radio' name='acqType' value='Birth'
                                    checked={this.state.selectedOption === 'Birth'}
                                    onChange={this.handleAcquisitionOptionChange}>
                                Birth
                            </Radio>
                            <Radio inline className='species-radio' name='acqType' value='Acquisition'
                                    checked={this.state.selectedOption === 'Acquisition'}
                                    onChange={this.handleAcquisitionOptionChange}>
                                Other Acquisition
                            </Radio>
                        </FormGroup>
                    </Col>
                    <Col className="col-md-8">
                        <Select
                                className="species-dropdown"
                                options={this.props.speciesList}
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
