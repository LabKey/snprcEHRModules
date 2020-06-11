import React from 'react';
import { Pager } from 'react-bootstrap';
import { LoadingSpinner } from "@labkey/components";
import './styles/newAnimalPage.scss';
import fetchSpecies from './actions/fetchSpecies';
import fetchAcquisitionTypes from './actions/fetchAcquisitionTypes';
import fetchPotentialDams from './actions/fetchPotentialDams';
import fetchPotentialSires from './actions/fetchPotentialSires';
import fetchLocations from './actions/fetchLocations';
import fetchAccounts from './actions/fetchAccounts';
import SpeciesPanel from './components/SpeciesPanel';
import AcquisitionPanel from './components/AcquisitionPanel';
import DemographicsPanel from './components/DemographicsPanel';
import LocationPanel from './components/LocationPanel';
import AccountPanel from './components/AccountPanel';
import DietPanel from './components/DietPanel';
import fetchColonies from './actions/fetchColonies';
import fetchProtocols from './actions/fetchProtocols';
import fetchInstitutions from './actions/fetchInstitutions';
import fetchPedigrees from './actions/fetchPedigrees';
import fetchDiets from './actions/fetchDiets';
import { isBirthdateValid } from './services/validation';
import NewAnimalState from './constants/NewAnimalState';
import { SaveModal, CancelChangeModal } from './components/Modals';
import constants from './constants/index';

export default class NewAnimalPage extends React.Component {

    state = new NewAnimalState();
    debug = constants.debug;
    numPanels = constants.numPanels;
    
    async componentDidMount (){
        try {
            const lists = {};
            console.log("Loading lists...");
    
            
                lists.dietList = await fetchDiets();
                lists.speciesList = await fetchSpecies();
                lists.accountList = await fetchAccounts();
                lists.institutionList = await fetchInstitutions();
            
                this.setState( prevState => (
                    {
                        ...prevState,
                        isLoading: false,
                        speciesList: lists.speciesList,
                        accountList: lists.accountList,
                        institutionList: lists.institutionList,
                        dietList: lists.dietList
                    }
                ))
            } catch(error) { console.log(error) };
    }

    disablePanels = () => (
        !(this.state.locationList && this.state.locationList.length > 0)
    )
    disableFirstPanel = () => (
        !this.state.selectedOption ||
        !this.state.newAnimalData.species
    )
    handleAcquisitionOptionChange = type => {
        fetchAcquisitionTypes(type).then(response => 
            this.setState(prevState => (
                {
                    ...prevState,
                    acquisitionTypeList: response,
                    selectedOption: type
                })
            )
        ).catch( (error) => {console.log(error)});
        
    }

    handleSpeciesChange = selectedSpecies => {
        if (this.state.newAnimalData.species !== undefined) {
            this.setState(prevState => (
                {
                    ...prevState,
                    showSpeciesChangeModal: true
                }
            ))
            return;
        }

        const lists = {}
        this.setState(prevState => (
            {
                ...prevState,
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    species: selectedSpecies
                }
            }
        ));

        async function loadListsAW(species, lists) {
            lists.potentialDamList = await fetchPotentialDams(species);
            lists.potentialSireList = await fetchPotentialSires(species);
            lists.locationList = await fetchLocations(species);
            lists.colonyList = await fetchColonies(species);
            lists.iacucList = await fetchProtocols(species);
            lists.pedigreeList = await fetchPedigrees(species);
        }


        loadListsAW(selectedSpecies.arcSpeciesCode, lists).then(() => {
            this.setState(prevState => (
                {
                    ...prevState,
                    potentialDamList: lists.potentialDamList,
                    potentialSireList: lists.potentialSireList,
                    locationList: lists.locationList,
                    colonyList: lists.colonyList,
                    iacucList: lists.iacucList,
                    pedigreeList: lists.pedigreeList,
                }
            ))
        }).catch((error) => {
            console.log(error);
        })
    }

    handleDataChange = (property, value) => {
        this.setState(prevState => (
            {
                ...prevState,
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    [property]: value
                }
            }
        ), this.preventNext);
    }

    handleNext = () => {
        this.setState(prevState => (
            {
                ...prevState,
                currentPanel: prevState.currentPanel < this.numPanels ? prevState.currentPanel + 1 : prevState.currentPanel
            }
        ));
    }
    handlePrevious = () => {
        this.setState(prevState => (
            {
                ...prevState,
                currentPanel: prevState.currentPanel > 1 ? prevState.currentPanel - 1 : prevState.currentPanel
            }
        ));
    }
    handleError = value => {
        this.setState(prevState => (
            {
                ...prevState,
                hasError: value
            }
        ))
    }
    // enable/disable pager controls
    preventNext = () => {
        let result = this.state.preventNext;

        if (this.debug) {
            result = false;
        }
        else {
            switch (this.state.currentPanel) {
                case 1:
                    result = this.state.newAnimalData.acquisitionType == undefined;
                    break;
                case 2:
                    result = this.state.newAnimalData.gender == undefined &&
                        isBirthdateValid(this.state.newAnimalData.birthDate.date, this.state.newAnimalData.acqDate.date);
                    break;
                case 3:
                    result = this.state.newAnimalData.room == undefined;
                    break;
                case 4:
                    result = ((this.state.newAnimalData.animalAccount == undefined ||
                        this.state.newAnimalData.ownerInstitution == undefined ||
                        this.state.newAnimalData.iacuc == undefined ||
                        this.state.newAnimalData.responsibleInstitution == undefined ||
                        (this.state.newAnimalData.colony == undefined && this.state.colonyList.length > 0) ||
                        (this.state.newAnimalData.pedigree == undefined && this.state.pedigreeList > 0)));
                    break;
                case 5:
                    result = this.state.newAnimalData.diet == undefined;
                    break;
                case 6:
                    result = false;
            }
        }
        this.setState(prevState => (
            {
                ...prevState,
                preventNext: result
            }
        ))
    }
    // fire save process
    onSaveClick = () => {
        console.log('Saving...');
        // run async save and dismiss modal
        this.setState(prevState => (
            {
                ...prevState,
                showSaveModal: false
            }
        ));
    }
    // save button callback
    handleSave = () => {
        console.log('Saving...');
        this.setState(prevState => (
            {
                ...prevState,
                showSaveModal: true
            }
        ));
    }
    // Cancel button callback
    handleCancel = () => {
        console.log('Cancelling...');
        this.setState(prevState => (
            {
                ...prevState,
                showCancelModal: true
            }
        ));

    }
    // reset app
    onCancelClick = () => {

        const initialState = new NewAnimalState();

        this.setState(() => (
            {
                ...initialState
            }
        ));
        this.loadLists();
    }
    // dismiss modals
    onCloseClick = () => {
        this.setState(prevState => (
            {
                ...prevState,
                showCancelModal: false,
                showSaveModal: false,
                showSpeciesChangeModal: false
            }
        ));
    }
    render() {
        let { isLoading } = this.state;

        if (isLoading) {
            return (
                <LoadingSpinner msg={'Loading lookup tables...'} />
            )
        }
        else {
            return (
                <div>
                    <div className="parent-panel">
                        <div className="panel-heading" disabled={this.state.currentPanel !== 1}>
                            <p>Species and Acquisition Type</p>
                        </div>
                        <div className="species-panel" disabled={this.state.currentPanel !== 1} >
                            <SpeciesPanel
                                handleAcquisitionOptionChange={this.handleAcquisitionOptionChange}
                                handleSpeciesChange={this.handleSpeciesChange}
                                speciesList={this.state.speciesList}
                                selectedOption={this.state.selectedOption}
                                disabled={this.state.currentPanel !== 1}
                                newAnimalData={this.state.newAnimalData}
                            />
                        </div>

                        {this.state.currentPanel == 1 &&
                            <div className="fade-in" >
                                <div className="panel-heading" disabled={this.disableFirstPanel()}>
                                    <p>Acquisition</p>
                                </div>
                                <div className="wizard-panel" disabled={this.disableFirstPanel()} >
                                    <AcquisitionPanel
                                        handleDataChange={this.handleDataChange}
                                        acquisitionTypeList={this.state.acquisitionTypeList}
                                        newAnimalData={this.state.newAnimalData}
                                        disabled={this.disableFirstPanel()}
                                        preventNext={this.preventNext}
                                    />
                                </div>
                            </div>
                        }

                        {this.state.currentPanel == 2 &&
                            <div className="fade-in">
                                <div className="panel-heading" disabled={this.disablePanels()}>
                                    <p>Demographics</p>
                                </div>
                                <div className="wizard-panel" disabled={this.disablePanels()}>
                                    <DemographicsPanel
                                        handleDataChange={this.handleDataChange}
                                        potentialDamList={this.state.potentialDamList}
                                        potentialSireList={this.state.potentialSireList}
                                        newAnimalData={this.state.newAnimalData}
                                        preventNext={this.preventNext}
                                        disabled={this.disablePanels()}
                                    />
                                </div>

                            </div>
                        }
                        {this.state.currentPanel == 3 &&
                            <div className="fade-in">
                                <div className="panel-heading" disabled={this.disablePanels()}>
                                    <p>Location</p>
                                </div>
                                <div className="wizard-panel" disabled={this.disablePanels()}>
                                    <LocationPanel
                                        locationList={this.state.locationList}
                                        handleDataChange={this.handleDataChange}
                                        newAnimalData={this.state.newAnimalData}
                                        handleError={this.handleError}
                                        preventNext={this.preventNext}
                                        disabled={this.disablePanels()}
                                    />
                                </div>
                            </div>
                        }

                        {this.state.currentPanel == 4 &&
                            <div className="fade-in">
                                <div className="panel-heading" disabled={this.disablePanels()}>
                                    <p>Account, Colony, and Ownership</p>
                                </div>
                                <div className="wizard-panel" disabled={this.disablePanels()}>
                                    <AccountPanel
                                        accountList={this.state.accountList}
                                        colonyList={this.state.colonyList}
                                        iacucList={this.state.iacucList}
                                        pedigreeList={this.state.pedigreeList}
                                        institutionList={this.state.institutionList}
                                        handleDataChange={this.handleDataChange}
                                        preventNext={this.preventNext}
                                        newAnimalData={this.state.newAnimalData}
                                        disabled={this.disablePanels()}
                                    />
                                </div>
                            </div>
                        }
                        {this.state.currentPanel == 5 &&
                            <div className="fade-in">
                                <div className="panel-heading" disabled={this.disablePanels()}>
                                    <p>Diet</p>
                                </div>
                                <div className="wizard-panel" disabled={this.disablePanels()}>
                                    <DietPanel
                                        dietList={this.state.dietList}
                                        handleDataChange={this.handleDataChange}
                                        newAnimalData={this.state.newAnimalData}
                                        preventNext={this.preventNext}
                                        disabled={this.disablePanels()}
                                    />
                                </div>
                            </div>
                        }
                    </div>

                    <div  >
                        <Pager className="pager-container">
                            <Pager.Item
                                onClick={this.handlePrevious}
                                disabled={(this.state.currentPanel <= 1) || this.state.hasError}
                                previous={true}
                            >
                                &larr; Previous Page
                            </Pager.Item>
                            {this.state.currentPanel !== this.numPanels &&
                                <Pager.Item
                                    onClick={this.handleNext}
                                    disabled={(this.state.currentPanel >= this.numPanels) || this.state.hasError || this.state.preventNext}
                                    next={true}
                                >
                                    Next Page &rarr;
                                </Pager.Item>
                            }
                            <Pager.Item
                                onClick={this.handleCancel}
                                disabled={false}
                                next={false}
                            >
                                Cancel
                            </Pager.Item>
                            {this.state.currentPanel == this.numPanels &&
                                <Pager.Item
                                    onClick={this.handleSave}
                                    disabled={(this.state.currentPanel !== this.numPanels) || this.state.hasError || !this.state.saveOk}
                                    next={true}
                                >
                                    Save
                                </Pager.Item>
                            }
                        </Pager>
                    </div>
                    <div >
                        {/* Save Modal */}
                        < SaveModal
                            show={this.state.showSaveModal}
                            onCloseClick={this.onCloseClick}
                            onSaveClick={this.onSaveClick}
                            newAnimalData={this.state.newAnimalData}
                        />
                        {/* Cancel Modal */}
                        < CancelChangeModal
                            show={this.state.showCancelModal}
                            yesClick={this.onCancelClick}
                            noClick={this.onCloseClick}
                            title={'Cancel changes?'}
                            message={'If you cancel now, you will lose all your changes. Are you sure you want to cancel?'}
                        />
                        {/* Species Change Modal */}
                        < CancelChangeModal
                            show={this.state.showSpeciesChangeModal}
                            yesClick={this.onCancelClick}
                            noClick={this.onCloseClick}
                            title={'Changes Species?'}
                            message={'If you change species now, you will lose all your changes. Are you sure you want to change species?'}
                        />
                    </div>
                </div>
            )
        }
    }
}

