import React from 'react';
import Row from 'react-bootstrap/lib/Row';
import Col from 'react-bootstrap/lib/Col';
import './styles/newAnimalPage.scss';
import { LoadingSpinner } from "@labkey/components";
import fetchSpecies from './actions/fetchSpecies';
import SpeciesPanel from './components/SpeciesPanel';
import AcquisitionPanel from './components/AcquisitionPanel';

export default class NewAnimalPage extends React.Component {

    state = {
        currentStep: 1,
        selectedOption: undefined,
        newAnimalData: {
            id: undefined,
            birthDate: undefined,
            acquisitionType: undefined,
            acqDate: undefined,
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
        acquisitionTypeList: [{label: 'Colony Born', id: 1, Value: 1}, {label: 'C-section', id: 2, Value: 2}],
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
    }
    handleAcquisitionChange = (selectedType) => {
        this.setState((prevState) => (
            {
                newAnimalData:
                {
                    ...prevState.newAnimalData,
                    acquisitionType: selectedType.value
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
                <div className="container-fluid page-wrapper">
                
                    <div className='species-wrapper' >

                                <SpeciesPanel
                                    handleAcquisitionOptionChange={this.handleAcquisitionOptionChange}
                                    handleSpeciesChange={this.handleSpeciesChange}
                                    speciesList={this.state.speciesList}
                                />
                    </div>
                    <div className='container-fluid wizard-panels'>
                        <Row>
                            <Col className="col-md-4">
                                    {this.state.currentStep == 1 && 
                                        <div className='acquisition-panel'>
                                            <label>Acquisition</label>
                                            <AcquisitionPanel
                                                handleAcquisitionChange={this.handleAcquisitionChange}
                                                acquisitionTypeList={this.state.acquisitionTypeList}
                                            />
                                        </div>
                                    }
                                    {this.state.currentStep == 2 && <div className='demographics-panel'><label>Demographics</label></div>}
                                    {this.state.currentStep == 3 && <div className='location-panel'><label>Location</label></div>}
                                    {this.state.currentStep == 4 && <div className='account-panel'><label>Account, Colony, and Ownership</label></div>}
                                    {this.state.currentStep == 5 && <div className='diet-panel'><label>Diet</label></div>}
                                
                            </Col>
                        </Row>
                    </div>

            </div>

            )
        }
    }
}

