import React from 'react';
import './styles/newAnimalPage.scss';
import { LoadingSpinner } from "@labkey/components";
import fetchSpecies from './actions/fetchSpecies';
import fetchAcquisitionTypes from './actions/fetchAcquisitionTypes';
import fetchPotentialDams from './actions/fetchPotentialDams';
import fetchPotentialSires from './actions/fetchPotentialSires';
import fetchLocations from './actions/fetchLocations';
import SpeciesPanel from './components/SpeciesPanel';
import AcquisitionPanel from './components/AcquisitionPanel';
import DemographicsPanel from './components/DemographicsPanel';
import LocationPanel from './components/LocationPanel';

export default class NewAnimalPage extends React.Component {

    state = {
        currentStep: 1,
        selectedOption: undefined,
        newAnimalData: {
            id: undefined,
            birthDate: undefined,
            acquisitionType: undefined,
            acqDate: new Date(),
            gender: 'U',
            sire: undefined,
            dam: undefined,
            species: undefined,
            arcSpeciesCode: undefined,
            colony: undefined,
            animalAccount: undefined,
            ownerInstitution: undefined,
            responsibleInstitution: undefined,
            room: undefined,
            cage: undefined,
            diet: undefined,
            pedigree: undefined,
            iacuc: undefined
        },
        speciesList: [],
        acquisitionTypeList: [],
        potentialpotentialDamList: [],
        potentialpotentialSireList: [],
        locationList: [],
        isLoaded: false

    };

    componentDidMount = () => {
        fetchSpecies().then(
            (response) => this.setState(() => (
                {
                    ...this.state,
                    isLoaded: true,
                    speciesList: response
                }
            )
            ));
    }

    handleLoadAcuisitionTypes = (type) => {
        fetchAcquisitionTypes(type).then(
            (response) => this.setState(() => (
                {
                    ...this.state,
                    isLoaded: true,
                    acquisitionTypeList: response
            })
        ));
    }

    handleAcquisitionOptionChange = (option) => {
        this.setState(() => (
            {
                ...this.state,
                selectedOption: option
            }
        ));
    }

    handleSpeciesChange = (selectedSpecies) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    species: selectedSpecies.value,
                    arcSpeciesCode: selectedSpecies.arcSpeciesCode
                }
            }
        ));

        fetchPotentialDams(selectedSpecies.arcSpeciesCode).then(
            (response) => this.setState(() => (
                {
                    ...this.state,
                    isLoaded: true,
                    potentialDamList: response
                }
            )
            ));
            fetchPotentialSires(selectedSpecies.arcSpeciesCode).then(
                (response) => this.setState(() => (
                    {
                        ...this.state,
                        isLoaded: true,
                        potentialSireList: response
                    }
                )
                ));
                fetchLocations(selectedSpecies.arcSpeciesCode).then(
                    (response) => this.setState(() => (
                        {
                            ...this.state,
                            isLoaded: true,
                            LocationList: response
                        }
                    )
                    ));
            
    }
    handleAcquisitionChange = ({value}) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    acquisitionType: value
                }
            }
        ));
    }
    handleAcquisitionDateChange = (date) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    acqDate: date
                }
            }
        ));
    }
    handleBirthDateChange = (date) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    birthDate: date
                }
            }
        ));
    }
    handleGenderChange = ({value} ) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    gender: value
                }
            }
        ));
    }
    handlePotentialDamChange = ({value}) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    dam: value
                }
            }
        ));
    }
    handlePotentialSireChange = ({value}) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    sire: value
                }
            }
        ));
    }

    handleRoomChange = ({value} ) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    room: value
                }
            }
        ));
    }
    handleCageChange = (value) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    cage: value
                }
            }
        ));
    }

    render() {
        let { isLoaded } = this.state;

        if (!isLoaded) {
            return (
                <LoadingSpinner  />
            )
        }
        else {
            return (
                <div>
                    <div className="container-fluid page-wrapper">
                        <div className='species-panel' >
                            <SpeciesPanel
                                handleAcquisitionOptionChange={this.handleAcquisitionOptionChange}
                                handleSpeciesChange={this.handleSpeciesChange}
                                speciesList={this.state.speciesList}
                                handleLoadAcuisitionTypes={this.handleLoadAcuisitionTypes}
                            />
                        </div>

                        <div className="panel-divider"></div>

                        {this.state.currentStep == 1 && 
                            <div>
                                <div className="wizard-label">
                                    <p>Acquisition</p>
                                </div>
                                <div className='acquisition-panel'>
                                    <AcquisitionPanel
                                        handleAcquisitionChange={this.handleAcquisitionChange}
                                        handleAcquisitionDateChange={this.handleAcquisitionDateChange}
                                        acquisitionTypeList={this.state.acquisitionTypeList}
                                        selectedOption={this.state.selectedOption}
                                        acquisitionDate={this.state.newAnimalData.acqDate}
                                    />
                                </div>
                            </div>
                        }

                    {this.state.currentStep == 1 && 
                        <div>
                            <div className="panel-divider"></div>
                            <div className="wizard-label">
                                <p>Demographics</p>
                            </div>
                            <div className='demographics-panel'>
                                <DemographicsPanel
                                    handleGenderChange={this.handleGenderChange}
                                    handleBirthDateChange={this.handleBirthDateChange}
                                    handlePotentialDamChange={this.handlePotentialDamChange}
                                    potentialDamList={this.state.potentialDamList}
                                    handlePotentialSireChange={this.handlePotentialSireChange}
                                    potentialSireList={this.state.potentialSireList}
                                    selectedOption={this.state.selectedOption}
                                    birthdate={this.state.newAnimalData.birthDate}
                                />
                            </div>
                        </div>
                    }

                        {this.state.currentStep == 1 && 
                            <div>
                            <div className="panel-divider"></div>
                                <div className="wizard-label">
                                    <p>Location</p>
                                </div>
                                <div className='location-panel'>
                                    <LocationPanel
                                        acquisitionDate={this.state.newAnimalData.acqDate}
                                        locationList={this.state.LocationList}
                                        room={this.state.newAnimalData.room}
                                        cage={this.state.newAnimalData.cage}
                                        handleRoomChange={this.handleRoomChange}
                                        handleCageChange={this.handleCageChange}
                                    />
                                </div>
                            </div>
                        }
                                        
                    {this.state.currentStep == 1 && 
                    <div className='account-panel'><label>Account, Colony, and Ownership</label></div>}
                    
                    {this.state.currentStep == 1 && 
                    <div className='diet-panel'><label>Diet</label></div>}
               
                </div>  
            </div>
            )
        }
    }
}

