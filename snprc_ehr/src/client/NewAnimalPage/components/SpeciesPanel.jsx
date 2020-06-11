import React from 'react';
import { Radio, FormGroup } from 'react-bootstrap';
import Select from 'react-select';

export default class SpeciesPanel extends React.Component {


    handleAcquisitionOptionChange = e => {
        const option = e.target.value;
        this.props.handleAcquisitionOptionChange(option);
    }
    handleSpeciesChange = value => {
        this.props.handleSpeciesChange( value);
    }
    render() {
        
        const {species} = this.props.newAnimalData;
        return (
            <div className="wizard-panel__rows">
                <div className='wizard-panel__row' >
                    <div className='wizard-panel__col radio-div'>
                        <label className="field-label-align-top" >Acquisition Type</label>
                        <FormGroup id="acquisition-radio-group" disabled={this.props.disabled}>
                            <Radio 
                                inline 
                                className='species-radio' 
                                name='acqType' 
                                value='Birth'
                                checked={this.props.selectedOption === 'Birth'}
                                onChange={this.handleAcquisitionOptionChange}
                                disabled={this.props.disabled}
                            >
                                Birth
                            </Radio>
                            <Radio 
                                inline 
                                className='species-radio' 
                                name='acqType' 
                                value='Acquisition'
                                checked={this.props.selectedOption === 'Acquisition'}
                                onChange={this.handleAcquisitionOptionChange}
                                disabled={this.props.disabled}
                            >
                                Other Acquisition
                            </Radio>
                        </FormGroup>
                    </div>
                    <div className='wizard-panel__col'>
                            <label className="field-label-align-close">Species</label>
                            <Select
                                value={species}
                                className="shared-dropdown shared-dropdown__species_width"
                                classNamePrefix="shared-select"
                                options={this.props.speciesList}
                                onChange={this.handleSpeciesChange}
                                placeholder="Select Species"
                                isDisabled={this.props.disabled}
                                isLoading={!this.props.speciesList}
                                isClearable={true}
                                id="species-select"
                            />
                    </div>
                </div>

            </div>
        )
    }
}
