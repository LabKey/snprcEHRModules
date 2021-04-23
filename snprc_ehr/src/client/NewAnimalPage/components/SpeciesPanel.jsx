import React from 'react'
import { Radio, FormGroup } from 'react-bootstrap'
import Select from 'react-select'

export default class SpeciesPanel extends React.Component {
    handleAcquisitionOptionChange = e => {
        const option = e.target.value
        this.props.handleAcquisitionOptionChange(option)
    }
handleSpeciesChange = value => {
        this.props.handleSpeciesChange(value)
    }
render() {
        const { species } = this.props.newAnimalData
        return (
          <div className="wizard-panel__rows">
            <div className="wizard-panel__row">
              <div className="wizard-panel__col radio-div">
                <label className="field-label-align-top">Acquisition Type</label>
                <FormGroup disabled={ this.props.disabled } id="acquisition-radio-group">
                  <Radio
                    checked={ this.props.selectedOption === 'Birth' }
                    className="species-radio"
                    disabled={ this.props.disabled }
                    inline
                    name="acqType"
                    onChange={ this.handleAcquisitionOptionChange }
                    value="Birth"
                  >
                    Birth
                  </Radio>
                  <Radio
                    checked={ this.props.selectedOption === 'Acquisition' }
                    className="species-radio"
                    disabled={ this.props.disabled }
                    inline
                    name="acqType"
                    onChange={ this.handleAcquisitionOptionChange }
                    value="Acquisition"
                  >
                    Other Acquisition
                  </Radio>
                </FormGroup>
              </div>
              <div className="wizard-panel__col">
                <label className="field-label-align-close">Species</label>
                <Select
                  className="shared-dropdown shared-dropdown__species_width"
                  classNamePrefix="shared-select"
                  id="species-select"
                  isDisabled={ this.props.disabled }
                  isLoading={ !this.props.speciesList }
                  onChange={ this.handleSpeciesChange }
                  options={ this.props.speciesList }
                  placeholder="Select Species"
                  value={ species }
                />
              </div>
            </div>
          </div>
        )
    }
}
