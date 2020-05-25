import React from 'react';
import './styles/newAnimalPage.scss';
import { LoadingSpinner } from "@labkey/components";
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
import { Pager } from 'react-bootstrap';

export default class NewAnimalPage extends React.Component {

    state = {
        currentPanel: 1,
        selectedOption: undefined,
        newAnimalData: {
            id: undefined,
            birthDate: { date: new Date(), hasError: false },
            acquisitionType: undefined,
            acqDate: { date: new Date() },
            gender: undefined,
            sire: undefined,
            dam: undefined,
            species: undefined,
            arcSpeciesCode: undefined,
            colony: undefined,
            animalAccount: undefined,
            ownerInstitution: undefined,
            responsibleInstitution: undefined,
            room: undefined,
            cage: { value: undefined, hasError: false },
            diet: undefined,
            pedigree: undefined,
            iacuc: undefined
        },
        speciesList: [],
        acquisitionTypeList: [],
        potentialDamList: [],
        potentialSireList: [],
        locationList: [],
        accountList: [],
        colonyList: [],
        institutionList: [],
        iacucList: [],
        pedigreeList: [],
        isLoading: true,
        hasError: false,
        preventNext: true,
        saveOk: true

    };
    debug = true;

    componentDidMount = () => {
        console.log("Loading...");
        const lists = {};

        async function loadListsAW(lists) {
            lists.speciesList = await fetchSpecies();
            lists.accountList = await fetchAccounts();
            lists.institutionList = await fetchInstitutions();
            lists.dietList = await fetchDiets();
        }

        loadListsAW(lists).then(() => {

            this.setState(prevState => (
                {
                    ...prevState,
                    isLoading: false,
                    speciesList: lists.speciesList,
                    accountList: lists.accountList,
                    institutionList: lists.institutionList,
                    dietList: lists.dietList
                }
            ))
        }).catch(error => { console.log(error) })
    }
    disablePanels = () => (
        !this.state.selectedOption ||
        !this.state.newAnimalData.species
    )
    disableFirstPanel = () => (
        !this.state.selectedOption
    )
    handleLoadAcuisitionTypes = type => {
        fetchAcquisitionTypes(type).then(response =>
            this.setState(prevState => (
                {
                    ...prevState,
                    acquisitionTypeList: response
                })
            ));
    }

    handleAcquisitionOptionChange = option => {
        this.setState(prevState => (
            {
                ...prevState,
                selectedOption: option
            }
        ));
    }

    handleSpeciesChange = selectedSpecies => {

        const lists = {}

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
                    newAnimalData:
                    {
                        ...prevState.newAnimalData,
                        species: selectedSpecies.value,
                        arcSpeciesCode: selectedSpecies.arcSpeciesCode
                    }
                }
            ))
            console.log("Species loaded");

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
        ));
    }
    handleNext = () => {
        this.setState(prevState => (
            {
                ...prevState,
                currentPanel: prevState.currentPanel < 5 ? prevState.currentPanel + 1 : prevState.currentPanel
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
    handleError = (value) => {
        this.setState(prevState => (
            {
                ...prevState,
                hasError: value
            }
        ))
    }
    preventNext = value => {
        this.setState(prevState => (
            {
                ...prevState,
                preventNext: value
            }

        ))
    }
    handleSave = () => {
        console.log('Saving...');
    }
    
    render() {
        let { isLoading } = this.state;

        if (isLoading) {
            return (
                <LoadingSpinner />
            )
        }
        else {
            return (
                <div>
                    <div className="parent-panel">
                        <div className="panel-heading">
                            <p>Species and Acquisition Type</p>
                        </div>
                        <div className="species-panel" >
                            <SpeciesPanel
                                handleAcquisitionOptionChange={this.handleAcquisitionOptionChange}
                                handleSpeciesChange={this.handleSpeciesChange}
                                handleLoadAcuisitionTypes={this.handleLoadAcuisitionTypes}
                                speciesList={this.state.speciesList}
                                selectedOption={this.state.selectedOption}
                                currentPanel={this.state.currentPanel}
                                disabled={this.disablePanels()}
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
                                        debug={this.debug}
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
                                        debug={this.debug}
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
                                        debug={this.debug}
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
                                        newAnimalData={this.state.newAnimalData}
                                        disabled={this.disablePanels()}
                                        debug={this.debug}
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
                                        disabled={this.disablePanels()}
                                        debug={this.debug}
                                    />
                                </div>
                            </div>
                        }
                    </div>

                    <div className="button-row" >
                        <Pager >
                            <Pager.Item
                                onClick={this.handlePrevious}
                                disabled={(this.state.currentPanel <= 1) || this.state.hasError}
                                previous={true}
                            >
                                &larr; Previous Page
                        </Pager.Item>
                        {this.state.currentPanel !== 5 &&
                            <Pager.Item
                                onClick={this.handleNext}
                                disabled={(this.state.currentPanel >= 5) || this.state.hasError || this.state.preventNext}
                                next={true}
                            >
                                Next Page &rarr;
                            </Pager.Item>
                        }
                        {this.state.currentPanel == 5 &&
                            <Pager.Item
                                onClick={this.handleSave}
                                disabled={(this.state.currentPanel !== 5) || this.state.hasError || !this.state.saveOk}
                                next={true}
                            >
                                Save
                        </Pager.Item>
        }
                        </Pager>
                    </div>
                </div>
            )
        }
    }
}

