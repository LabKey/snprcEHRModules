import React from 'react'
import Select from 'react-select'

export default class AnimalSelectionPanel extends React.Component {
    handleChange = option => {
        this.props.handleChange(option)
    }
render() {
        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <label className="field-label-align-close">Animal</label>
                  <Select
                    autoFocus
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    id="animal-select"
                    isClearable
                    isLoading={ !this.props.animalList }
                    onChange={ this.handleChange }
                    options={ this.props.animalList }
                    placeholder="Select Animal"
                    value={ this.props.selectedAnimal || null }
                  />
                </div>
              </div>
            </div>
          </>
        )
    }
}
