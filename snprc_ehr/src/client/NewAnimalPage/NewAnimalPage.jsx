import React from 'react';
import Container from 'react-bootstrap/Container'
import FormLabel from 'react-bootstrap/FormLabel'
import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import Spinner from 'react-bootstrap/Spinner'
import fetchSpecies from './actions/fetchSpecies'
import SpeciesPanel from './components/SpeciesPanel'
import './styles/newAnimalPage.scss';

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
        speciesMap: [],
        isLoaded: false

    };

    componentDidMount = () => {
        fetchSpecies().then(
            (response) => this.setState(() => (
                {
                    ...this.state,
                    isLoaded: true,
                    speciesMap: response
                }
            )
            ));
    }

    handleAcquisitionChange = (option) => {
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
    render() {
        let { isLoaded } = this.state;

        if (!isLoaded) {
            return (
                <Spinner animation="border" role="status" size="lg" />
            )
        }
        else {
            return (
                <div className="page-wrapper">
                <Container >
                    <div className='species-wrapper' >
                        <Row>
                            <Col className="col-md-12">
                                <SpeciesPanel
                                    handleAcquisitionChange={this.handleAcquisitionChange}
                                    handleSpeciesChange={this.handleSpeciesChange}
                                    speciesMap={this.state.speciesMap}
                                />
                            </Col>
                        </Row>
                    </div>
                </Container>
                <Container>
                    <div className='wizard-panels'>
                        <Row>
                            <Col className="col-md-4">
                                    {this.state.currentStep == 1 && <div className='acquisition-panel'><FormLabel>Acquisition</FormLabel>
                                    </div>}
                                    {this.state.currentStep == 2 && <div className='demographics-panel'><FormLabel>Demographics</FormLabel></div>}
                                    {this.state.currentStep == 3 && <div className='location-panel'><FormLabel>Location</FormLabel></div>}
                                    {this.state.currentStep == 4 && <div className='account-panel'><FormLabel>Account, Colony, and Ownership</FormLabel></div>}
                                    {this.state.currentStep == 5 && <div className='diet-panel'><FormLabel>Diet</FormLabel></div>}
                                
                            </Col>
                        </Row>
                    </div>
                </Container >
            </div>

            )
        }
    }
}

