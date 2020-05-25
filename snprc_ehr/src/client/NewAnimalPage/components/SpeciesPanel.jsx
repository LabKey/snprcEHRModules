import React from 'react';
import FormGroup from 'react-bootstrap/lib/FormGroup';
import { Col, Row, Radio, Pager, Label } from 'react-bootstrap';
import Select from 'react-select';

export default class SpeciesPanel extends React.Component {


    handleAcquisitionOptionChange = e => {
        const option = e.target.value;
        this.props.handleAcquisitionOptionChange(option);
        this.props.handleLoadAcuisitionTypes(option);
    }
    handleSpeciesChange = value => {
        this.props.handleSpeciesChange(value);
    }
    render() {
        return (
            <div className="wizard-panel__rows">
                <div className='wizard-panel__row' >

                    <div className='wizard-panel__col'>
                        {/* </div><Col md={4}> */}

                        <label className="field-label-align-top" >Acquisition Type</label>
                        <FormGroup id="acquisition-radio-group">
                            <Radio inline className='species-radio' name='acqType' value='Birth'
                                checked={this.props.selectedOption === 'Birth'}
                                onChange={this.handleAcquisitionOptionChange}>
                                Birth
                            </Radio>
                            <Radio inline className='species-radio' name='acqType' value='Acquisition'
                                checked={this.props.selectedOption === 'Acquisition'}
                                onChange={this.handleAcquisitionOptionChange}>
                                Other Acquisition
                            </Radio>
                        </FormGroup>
                        {/* </Col> */}
                    </div>

                    <div className='wizard-panel__col'>
                        <div className='top-spacing'></div>
                        {/* <Col md={6} mdOffset={1}> */}
                            <label className="field-label-align-close" >Species</label>
                            <Select
                                className="shared-dropdown shared-dropdown__species_width"
                                classNamePrefix="shared-select"
                                options={this.props.speciesList}
                                onChange={this.handleSpeciesChange}
                                placeholder="Select Species"
                                isDisabled={false}
                                isLoading={!this.props.speciesList}
                                id="species-select"
                            />
                        {/* </Col> */}
                    </div>
                </div>

            </div>
        )
    }
}
