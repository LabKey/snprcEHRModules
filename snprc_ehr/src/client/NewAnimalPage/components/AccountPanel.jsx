import React from 'react'
import Select from 'react-select'
import InfoPanel from '../../Shared/components/InfoPanel'

export default class AccountPanel extends React.Component {
  componentDidMount = () => {
    this.props.preventNext()
  }

  handleAccountChange = option => {
    this.props.handleDataChange('animalAccount', option)
  }

  handleColonyChange = option => {
    this.props.handleDataChange('colony', option)
  }

  handleOwnerInstitutionChange = option => {
    this.props.handleDataChange('ownerInstitution', option)
  }

  handleIacucChange = option => {
    this.props.handleDataChange('iacuc', option)
  }

  handlePedigreeChange = option => {
    this.props.handleDataChange('pedigree', option)
  }

  handleResponsibleInstitutionChange = option => {
    this.props.handleDataChange('responsibleInstitution', option)
  }

  render() {
    const { animalAccount, colony, pedigree, iacuc, responsibleInstitution, ownerInstitution } = this.props.newAnimalData

    return (
      <>
        <div className="wizard-panel__rows" id="account-panel">
          <div className="wizard-panel__row" id="account-row">
            <div className="wizard-panel__col">
              <label className="field-label">Account</label>
              <Select
                autoFocus
                className="shared-dropdown"
                classNamePrefix="shared-select"
                defaultValue={ animalAccount }
                id="account-select"
                isClearable
                isDisabled={ this.props.disabled }
                isLoading={ this.props.accountList.length === 0 }
                onChange={ this.handleAccountChange }
                options={ this.props.accountList }
                placeholder="Select Account"
              />
            </div>
          </div>
          {this.props.colonyList.length > 0
            && (
              <div className="wizard-panel__row" id="colony-row">
                <div className="wizard-panel__col">
                  <label className="field-label">Colony</label>
                  <Select
                    className="shared-dropdown"
                    classNamePrefix="shared-select"
                    defaultValue={ colony }
                    id="colony-select"
                    isClearable
                    isDisabled={ this.props.disabled }
                    isLoading={ this.props.colonyList.length === 0 }
                    onChange={ this.handleColonyChange }
                    options={ this.props.colonyList }
                    placeholder="Select Colony"
                  />
                </div>
              </div>
            )}
          <div className="wizard-panel__row" id="iacuc-row">
            <div className="wizard-panel__col">
              <label className="field-label">IACUC</label>
              <Select
                className="shared-dropdown"
                classNamePrefix="shared-select"
                defaultValue={ iacuc }
                id="iacuc-select"
                isClearable
                isDisabled={ this.props.disabled }
                isLoading={ this.props.iacucList.length === 0 }
                onChange={ this.handleIacucChange }
                options={ this.props.iacucList }
                placeholder="Select IACUC"
              />
            </div>
          </div>
          {this.props.pedigreeList.length > 0 && (
            <div className="wizard-panel__row" id="pedigree-row">
              <div className="wizard-panel__col">
                <label className="field-label">Pedigree</label>
                <Select
                  className="shared-dropdown"
                  classNamePrefix="shared-select"
                  defaultValue={ pedigree }
                  id="pedigree-select"
                  isClearable
                  isDisabled={ this.props.disabled }
                  isLoading={ this.props.pedigreeList.length === 0 }
                  onChange={ this.handlePedigreeChange }
                  options={ this.props.pedigreeList }
                  placeholder="Select Pedigree"
                />
              </div>
            </div>
          )}
          <div className="wizard-panel__row" id="owner-institution-row">
            <div className="wizard-panel__col">
              <label className="field-label">Owner</label>
              <Select
                className="shared-dropdown"
                classNamePrefix="shared-select"
                id="owner-select"
                isClearable
                isDisabled={ this.props.disabled }
                isLoading={ this.props.institutionList.length === 0 }
                onChange={ this.handleOwnerInstitutionChange }
                options={ this.props.institutionList }
                placeholder="Select Owner"
                value={ ownerInstitution }
              />
            </div>
          </div>
          <div className="wizard-panel__row" id="responsible-institution-row">
            <div className="wizard-panel__col">
              <label className="field-label">Responsible Institution</label>
              <Select
                className="shared-dropdown"
                classNamePrefix="shared-select"
                id="responsible-institution-select"
                isClearable
                isDisabled={ this.props.disabled }
                isLoading={ this.props.institutionList.length === 0 }
                onChange={ this.handleResponsibleInstitutionChange }
                options={ this.props.institutionList }
                placeholder="Select Responsible Institution"
                value={ responsibleInstitution }
              />
            </div>
          </div>
        </div>
        <InfoPanel
          messages={
            [{ propTest: !animalAccount, colName: 'Account' },
            { propTest: (!colony && this.props.colonyList.length > 0), colName: 'Colony' },
            { propTest: !iacuc, colName: 'IACUC' },
            { propTest: (!pedigree && this.props.pedigreeList.length > 0), colName: 'Pedigree' },
            { propTest: !ownerInstitution, colName: 'Owner' },
            { propTest: !responsibleInstitution, colName: 'Responsible Institution' }
            ]
          }
        />
      </>
    )
  }
}
