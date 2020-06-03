import React from 'react';
import Select from 'react-select';
import InfoPanel from './InfoPanel';


export default class AccountPanel extends React.Component {

    state = {
        newAnimalData: this.props.newAnimalData
    }
    
    componentDidMount = () => {
        this.props.preventNext();
    }

    handleAccountChange = option => {
        this.props.handleDataChange('animalAccount', option);
    }
    handleColonyChange = option => {
        this.props.handleDataChange('colony', option);
    }
    handleOwnerInstitutionChange = option => {
        this.props.handleDataChange('ownerInstitution', option);
    }
    handleIacucChange = option => {
        this.props.handleDataChange('iacuc', option);
    }
    handlePedigreeChange = option => {
        this.props.handleDataChange('pedigree', option);
    }
    handleResponsibleInstitutionChange = option => {
        this.props.handleDataChange('responsibleInstitution', option);
    }

    render() {

        let { animalAccount, colony, pedigree, iacuc, responsibleInstitution, ownerInstitution } = this.props.newAnimalData;
        
        return (
            <>
                <div className="wizard-panel__rows" id="account-panel">
                    <div className='wizard-panel__row' id="account-row" >
                        <div className='wizard-panel__col'>
                            <label className="field-label" >Account</label>
                            <Select
                                defaultValue={animalAccount}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.accountList}
                                onChange={this.handleAccountChange}
                                placeholder="Select Account"
                                isDisabled={this.props.disabled}
                                isClearable={true}
                                isLoading={this.props.accountList.length === 0}
                                id="account-select"
                                autoFocus
                            />
                        </div>
                    </div>
                    {this.props.colonyList.length > 0 && 
                        <div className='wizard-panel__row' id="colony-row" >
                            <div className='wizard-panel__col'>
                                <label className="field-label" >Colony</label>
                                <Select
                                    defaultValue={colony}
                                    className="shared-dropdown"
                                    classNamePrefix="shared-select"
                                    options={this.props.colonyList}
                                    onChange={this.handleColonyChange}
                                    placeholder="Select Colony"
                                    isDisabled={this.props.disabled}
                                    isClearable={true}
                                    isLoading={this.props.colonyList.length === 0}
                                    id="colony-select"
                                />
                            </div>
                        </div>
                    }
                    <div className='wizard-panel__row' id="iacuc-row" >
                        <div className='wizard-panel__col'>
                            <label className="field-label" >IACUC</label>
                            <Select
                                defaultValue={iacuc}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.iacucList}
                                onChange={this.handleIacucChange}
                                placeholder="Select IACUC"
                                isDisabled={this.props.disabled}
                                isClearable={true}
                                isLoading={this.props.iacucList.length === 0}
                                id="iacuc-select"
                            />
                        </div>
                    </div>
                    {this.props.pedigreeList.length > 0  && //this.state.showPedigree &&
                        <div className='wizard-panel__row' id="pedigree-row" >
                            <div className='wizard-panel__col'>
                                <label className="field-label" >Pedigree</label>
                                <Select
                                    defaultValue={pedigree}
                                    className="shared-dropdown"
                                    classNamePrefix="shared-select"
                                    options={this.props.pedigreeList}
                                    onChange={this.handlePedigreeChange}
                                    placeholder="Select Pedigree"
                                    isDisabled={this.props.disabled}
                                    isClearable={true}
                                    isLoading={this.props.pedigreeList.length === 0}
                                    id="pedigree-select"
                                />
                            </div>
                        </div>
                    }
                    <div className='wizard-panel__row' id="owner-institution-row">
                        <div className='wizard-panel__col'>
                            <label className="field-label" >Owner</label>
                            <Select
                                defaultValue={ownerInstitution}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.institutionList}
                                onChange={this.handleOwnerInstitutionChange}
                                placeholder="Select Owner"
                                isDisabled={this.props.disabled}
                                isClearable={true}
                                isLoading={this.props.institutionList.length === 0}
                                id="owner-select"
                            />
                        </div>
                    </div>
                    <div className='wizard-panel__row' id="responsible-institution-row">
                        <div className='wizard-panel__col'>
                            <label className="field-label" >Responsible Institution</label>
                            <Select
                                defaultValue={responsibleInstitution}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.institutionList}
                                onChange={this.handleResponsibleInstitutionChange}
                                placeholder="Select Responsible Institution"
                                isDisabled={this.props.disabled}
                                isClearable={true}
                                isLoading={this.props.institutionList.length === 0}
                                id="responsible-institution-select"
                            />
                        </div>
                    </div>
                </div>
                <InfoPanel 
                    messages={ 
                        [ {propTest: !animalAccount, colName: "Account"},
                          {propTest: (!colony && this.props.colonyList.length > 0), colName: "Colony"},
                          {propTest: !iacuc, colName: "IACUC"},
                          {propTest: (!pedigree && this.props.pedigreeList.length > 0), colName: "Pedigree"},
                          {propTest: !ownerInstitution, colName: "Owner"},
                          {propTest: !responsibleInstitution, colName: "Responsible Institution"}
                        ]
                    }
                        
                />
            </> 
        )
    }
}
