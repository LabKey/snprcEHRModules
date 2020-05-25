import React from 'react';
import Select from 'react-select';


export default class AccountPanel extends React.Component {

    handleAccountChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('animalAccount', validatedOption);
    }
    handleColonyChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('colony', validatedOption);
    }
    handleOwnerInstitutionChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('ownerInstitution', validatedOption);
    }
    handleIacucChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('iacuc', validatedOption);
    }
    handlePedigreeChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('pedigree', validatedOption);
    }
    handleResponsibleInstitutionChange = option => {
        const validatedOption = this.validate(option);
        this.props.handleDataChange('responsibleInstitution', validatedOption);
    }
    validate = option => {
        return ({
            ...option,
            hasError: false
        })
    }
    render() {
        let { animalAccount, colony, pedigree, iacuc, responsibleInstitution, ownerInstitution } = this.props.newAnimalData;
        return (
            <>
                <div className="wizard-panel__rows">
                    <div className='wizard-panel__row' >
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
                                isLoading={this.props.accountList.length === 0}
                                id="account-select"
                            />
                        </div>
                    </div>
                    { this.props.colonyList &&
                        <div className='wizard-panel__row' >
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
                                    isLoading={this.props.colonyList.length === 0}
                                    id="colony-select"
                                />
                            </div>
                        </div>
                    }
                    <div className='wizard-panel__row' >
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
                                isLoading={this.props.iacucList.length === 0}
                                id="iacuc-select"
                            />
                        </div>
                    </div>
                    <div className='wizard-panel__row' >
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
                                isLoading={this.props.pedigreeList.length === 0}
                                id="pedigree-select"
                            />
                        </div>
                    </div>
                    <div className='wizard-panel__row' >
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
                                isLoading={this.props.institutionList.length === 0}
                                id="owner-select"
                            />
                        </div>
                    </div>
                    <div className='wizard-panel__row' >
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
                                isLoading={this.props.institutionList.length === 0}
                                id="responsible-institution-select"
                            />
                        </div>
                    </div>
                </div>
                <div className="error-panel">
                    {!colony && 'You must select a location.'}
                </div>
            </>
        )
    }
}
