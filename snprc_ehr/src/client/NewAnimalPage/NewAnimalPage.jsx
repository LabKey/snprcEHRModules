import React from 'react';
import { Pager } from 'react-bootstrap';
import { LoadingSpinner } from "@labkey/components";
import './styles/newAnimalPage.scss';
import NewAnimalState from './constants/NewAnimalState';
import constants from './constants/index';
import fetchSpecies from './api/fetchSpecies';
import fetchAcquisitionTypes from './api/fetchAcquisitionTypes';
import fetchPotentialDams from './api/fetchPotentialDams';
import fetchPotentialSires from './api/fetchPotentialSires';
import fetchLocations from './api/fetchLocations';
import fetchAccounts from './api/fetchAccounts';
import fetchColonies from './api/fetchColonies';
import fetchProtocols from './api/fetchProtocols';
import fetchInstitutions from './api/fetchInstitutions';
import fetchPedigrees from './api/fetchPedigrees';
import fetchDiets from './api/fetchDiets';
import fetchBdStatus from './api/fetchBdStatus';
import AcquisitionPanel from './components/AcquisitionPanel';
import DemographicsPanel from './components/DemographicsPanel';
import LocationPanel from './components/LocationPanel';
import AccountPanel from './components/AccountPanel';
import DietPanel from './components/DietPanel';
import SpeciesPanel from './components/SpeciesPanel';
import InfoPanel from './components/InfoPanel';
import { isBirthdateValid } from './services/validation';
import { SaveModal, CancelChangeModal, SuccessModal } from './components/Modals';
import { uploadAnimalData, formatDataForUpload } from './api/UpdateAnimalData';

export default class NewAnimalPage extends React.Component {

    state = new NewAnimalState();
    debug = constants.debug;
    numPanels = constants.numPanels;

    componentDidMount() {
        Promise.resolve(this.loadLists()).catch = error => { console.log(`Error in componentDidMount: ${error}`)};
    }
    
    loadLists() {
        const lists = {};
        console.log("Loading lists...");

        Promise.all([
            fetchBdStatus().then( list => { lists.bdStatusList = list }),
            fetchDiets().then( list => { lists.dietList = list }), 
            fetchSpecies().then( list => { lists.speciesList = list }),
            fetchAccounts().then( list => { lists.accountList = list }), 
            fetchInstitutions().then( list => { lists.institutionList = list })
        ]).then(() => {
            this.setState(prevState => (
                {
                    ...prevState,
                    isLoading: false,
                    speciesList: lists.speciesList,
                    accountList: lists.accountList,
                    institutionList: lists.institutionList,
                    dietList: lists.dietList,
                    bdStatusList: lists.bdStatusList
                }
            ))
        }).catch(error => { console.log(`Error in loadLists: ${error}`) });
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
        ).catch( error => { console.log(error) });

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
        this.setState( prevState => (
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
        }).catch( error => {
            console.log(`Error in handleSpeciesChange: ${error}`);
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

        const {acquisitionType, gender, bdStatus, room, animalAccount, ownerInstitution, iacuc, 
                responsibleInstitution, colony, pedigree, diet, birthDate, acqDate} = this.state.newAnimalData;

        let result = this.state.preventNext;

        if (this.debug) {
            result = false;
        }
        else {
            switch (this.state.currentPanel) {
                case 1:
                    result = !acquisitionType;
                    break;
                case 2:
                    result = !gender || !bdStatus || !isBirthdateValid(birthDate.date, acqDate.date);
                    break;
                case 3:
                    result = !room;
                    break;
                case 4:
                    result = !animalAccount || !ownerInstitution || !iacuc || !responsibleInstitution  ||
                        (!colony && this.state.colonyList.length > 0) || (!pedigree && this.state.pedigreeList > 0);
                    break;
                case 5:
                    result = !diet;
                    break;
                case 6:
                    result = false;
            }
        }
        this.setState( prevState => (
            {
                ...prevState,
                preventNext: result
            }
        ))
    }
    // save process
    onSaveClick = () => {
        console.log('Saving...');

        // run async save and dismiss modal
        const jsonData = formatDataForUpload(this.state.newAnimalData);

        uploadAnimalData(jsonData).then( data => {
            if (data.success === true) {
                this.setState(prevState => (
                    {
                        ...prevState,
                        newAnimalData:
                        {
                            ...prevState.newAnimalData,
                            id: data.Id
                        },
                        showSaveModal: false,
                        showSuccessModal: true
                    }
                ));
            }
            else {
                this.setState(prevState => (
                    {
                        ...prevState,
                        errorMessage: data.message,
                        showSaveModal: false
                    }
                ));
            }
        }).catch(error => {
            this.setState(prevState => (
                {
                    ...prevState,
                    errorMessage: error.exception,
                    showSaveModal: false
                }
            ));
        });
    }
    // save button callback
    handleSave = () => {
        this.setState(prevState => (
            {
                ...prevState,
                showSaveModal: true
            }
        ));
    }
    // Cancel button callback
    handleCancel = () => {
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
                showSpeciesChangeModal: false,
                showSuccessModal: false
            }
        ));
    }
    render() {

        // allow debug mode to be triggered for running test suite
        this.debug = this.props.debug !== undefined ? this.props.debug : constants.debug;

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
                                        bdStatusList={this.state.bdStatusList}
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
                        <InfoPanel
                            errorMessages={this.state.errorMessage && [{ propTest: true, colName: this.state.errorMessage }]}
                        />
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
                                    disabled={(this.state.currentPanel !== this.numPanels) || this.state.hasError || this.state.preventNext}
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
                        < SuccessModal
                            show={this.state.showSuccessModal}
                            okClick={this.onCloseClick}
                            newAnimalData={this.state.newAnimalData}
                        />
                    </div>
                </div>
            )
        }
    }
}

