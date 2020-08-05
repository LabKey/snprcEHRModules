/* eslint-disable no-alert */

import React from 'react'
import moment from 'moment'
import { Pager } from 'react-bootstrap'
import { LoadingSpinner } from '@labkey/components'
import './styles/newAnimalPage.scss'
import NewAnimalState from './constants/NewAnimalState'
import constants from './constants/index'
import fetchSpecies from './api/fetchSpecies'
import fetchAcquisitionTypes from './api/fetchAcquisitionTypes'
import fetchPotentialDams from './api/fetchPotentialDams'
import fetchPotentialSires from './api/fetchPotentialSires'
import fetchLocations from './api/fetchLocations'
import fetchAccounts from './api/fetchAccounts'
import fetchColonies from './api/fetchColonies'
import fetchProtocols from './api/fetchProtocols'
import fetchInstitutions from './api/fetchInstitutions'
import fetchPedigrees from './api/fetchPedigrees'
import fetchDiets from './api/fetchDiets'
import fetchBdStatus from './api/fetchBdStatus'
import AcquisitionPanel from './components/AcquisitionPanel'
import DemographicsPanel from './components/DemographicsPanel'
import LocationPanel from './components/LocationPanel'
import AccountPanel from './components/AccountPanel'
import DietPanel from './components/DietPanel'
import SpeciesPanel from './components/SpeciesPanel'
import InfoPanel from '../Shared/components/InfoPanel'
import SummaryGridPanel from './components/SummaryGridPanel'
import CancelChangeModal from './components/CancelChangeModal'
import SaveModal from './components/SaveModal'
import { isBirthdateValid } from './services/validation'
import { uploadAnimalData } from './api/updateAnimalData'
import { getReportPath } from './services/printToPDF'

export default class NewAnimalPage extends React.Component {
  state = new NewAnimalState();

  debug = constants.debug;

  numPanels = constants.numPanels;

  selectedSpecies = undefined;

  componentDidMount() {
    // prevent user from navigating away from page
    window.addEventListener('beforeunload', this.beforeunload.bind(this))

    Promise.resolve(this.loadLists()).catch = error => {
      console.log(`Error in componentDidMount: ${error}`)
    }
  }

  componentWillUnmount() {
    window.removeEventListener(
      'beforeunload',
      this.beforeunload.bind(this)
    )
  }

  beforeunload(e) {
    if (this.state.isDirty) {
      e.preventDefault()
      e.returnValue = true
    }
  }

  loadLists() {
    const lists = {}
    console.log('Loading lists...')

    Promise.all([
      fetchBdStatus().then(list => {
        lists.bdStatusList = list
      }),
      fetchDiets().then(list => {
        lists.dietList = list
      }),
      fetchSpecies().then(list => {
        lists.speciesList = list
      }),
      fetchAccounts().then(list => {
        lists.accountList = list
      }),
      fetchInstitutions().then(list => {
        lists.institutionList = list
      }),
    ])
      .then(() => {
        this.setState(prevState => ({
          ...prevState,
          isLoading: false,
          speciesList: lists.speciesList,
          accountList: lists.accountList,
          institutionList: lists.institutionList,
          dietList: lists.dietList,
          bdStatusList: lists.bdStatusList,
        }))
      })
      .catch(error => {
        console.log(`Error in loadLists: ${error}`)
        this.setState(prevState => ({
          ...prevState,
          errorMessage: error.message,
        }))
      })
  }

  loadListsForSpecies = selectedSpecies => {
    const lists = {}

    async function loadListsAW(species) {
      lists.potentialDamList = await fetchPotentialDams(species)
      lists.potentialSireList = await fetchPotentialSires(species)
      lists.locationList = await fetchLocations(species)
      lists.colonyList = await fetchColonies(species)
      lists.iacucList = await fetchProtocols(species)
      lists.pedigreeList = await fetchPedigrees(species)
    }

    loadListsAW(selectedSpecies.arcSpeciesCode)
      .then(() => {
        this.setState(prevState => ({
          ...prevState,
          potentialDamList: lists.potentialDamList,
          potentialSireList: lists.potentialSireList,
          locationList: lists.locationList,
          colonyList: lists.colonyList,
          iacucList: lists.iacucList,
          pedigreeList: lists.pedigreeList,
        }))
      })
      .catch(error => {
        console.log(`Error in handleSpeciesChange: ${error}`)
        this.setState(prevState => ({
          ...prevState,
          errorMessage: error.message,
        }))
      })
  };

  disablePanels = () => !(this.state.locationList && this.state.locationList.length > 0);

  disableFirstPanel = () => !this.state.selectedOption || !this.state.newAnimalData.species;

  handleAcquisitionOptionChange = type => {
    fetchAcquisitionTypes(type)
      .then(response => this.setState(prevState => ({
        ...prevState,
        isDirty: true,
        acquisitionTypeList: response,
        selectedOption: type,
        newAnimalData: {
          ...prevState.newAnimalData,
          acquisitionType: undefined,
          selectedOption: type,
        },
      })))
      .catch(error => {
        console.log(error)
      })
  };

  handleSpeciesChange = selectedSpecies => {
    // ignore sub-species change
    if (
      this.state.newAnimalData.species !== undefined
      && this.state.newAnimalData.species.arcSpeciesCode
      !== selectedSpecies.arcSpeciesCode
    ) {
      this.selectedSpecies = selectedSpecies
      this.setState(prevState => ({
        ...prevState,
        showSpeciesChangeModal: true,
      }))
    } else {
      this.setState(prevState => ({
        ...prevState,
        isDirty: true,
        newAnimalData: {
          ...prevState.newAnimalData,
          species: selectedSpecies,
        },
      }))
      this.loadListsForSpecies(selectedSpecies)
    }
  };

  handleDataChange = (property, value) => {
    this.setState(
      prevState => ({
        ...prevState,
        isDirty: true,
        newAnimalData: {
          ...prevState.newAnimalData,
          [property]: value,
          ...(property === 'acqDate'
            && prevState.selectedOption === 'Birth' && {
            birthDate: value,
          }),
        },
      }),
      this.preventNext
    )
  };

  handleNext = () => {
    this.setState(prevState => ({
      ...prevState,
      currentPanel:
        prevState.currentPanel < this.numPanels
          ? prevState.currentPanel + 1
          : prevState.currentPanel,
    }))
  };

  handlePrevious = () => {
    this.setState(prevState => ({
      ...prevState,
      currentPanel:
        prevState.currentPanel > 1
          ? prevState.currentPanel - 1
          : prevState.currentPanel,
    }))
  };

  handleError = value => {
    this.setState(prevState => ({
      ...prevState,
      hasError: value,
    }))
  };

  // enable/disable pager controls
  preventNext = () => {
    const {
      acquisitionType,
      gender,
      bdStatus,
      room,
      animalAccount,
      ownerInstitution,
      iacuc,
      responsibleInstitution,
      colony,
      pedigree,
      diet,
      birthDate,
      acqDate,
    } = this.state.newAnimalData

    let result = this.state.preventNext

    if (this.debug) {
      result = false
    } else {
      switch (this.state.currentPanel) {
        case 1:
          result = !acquisitionType
          break
        case 2:
          result = !gender
            || !bdStatus
            || !isBirthdateValid(birthDate.date, acqDate.date)
          break
        case 3:
          result = !room
          break
        case 4:
          result = !animalAccount
            || !ownerInstitution
            || !iacuc
            || !responsibleInstitution
            || (!colony && this.state.colonyList.length > 0)
            || (!pedigree && this.state.pedigreeList > 0)
          break
        case 5:
          result = !diet
          break
        case 6:
          result = false
          break
        default:
          break
      }
    }
    this.setState(prevState => ({
      ...prevState,
      preventNext: result,
    }))
  };

  // save process
  onSaveClick = () => {
    console.log('Saving...')

    // run async save then dismiss modal
    uploadAnimalData(this.state.newAnimalData)
      .then(data => {
        if (data.success === true) {
          this.setState(
            prevState => ({
              ...prevState,
              newAnimalData: {
                ...prevState.newAnimalData,
                id: data.Id,
              },
              showSaveModal: false,
              summaryData: [
                ...prevState.summaryData,
                { ...prevState.newAnimalData, id: data.Id },
              ],
            }),
            this.handleSaveReset()
          )
        } else {
          this.setState(prevState => ({
            ...prevState,
            errorMessage: data.message,
            showSaveModal: false,
          }))
        }
      })
      .catch(error => {
        this.setState(prevState => ({
          ...prevState,
          errorMessage: error.exception,
          showSaveModal: false,
        }))
      })
  };

  handleSaveReset = () => {
    this.setState(prevState => ({
      ...prevState,
      currentPanel: 1,
      newAnimalData: {
        ...prevState.newAnimalData,
        ...(prevState.selectedOption === 'Acquisition' && {
          birthDate: { date: moment() },
        }),
        ...(prevState.selectedOption === 'Acquisition' && {
          bdStatus: undefined,
        }),
        gender: undefined,
        ...((prevState.newAnimalData.species.arcSpeciesCode === 'CJ' && prevState.selectedOption === 'Birth' && {
          sire: prevState.newAnimalData.sire,
          dam: prevState.newAnimalData.dam,
          cage: prevState.newAnimalData.cage

        })
        || {
          sire: undefined,
          dam: undefined,
          cage: { value: undefined }
        }
        ),
      },
    }))
  };

  // save button callback
  handleSave = () => {
    this.setState(prevState => ({
      ...prevState,
      showSaveModal: true,
    }))
  };

  // Cancel button callback
  handleCancel = () => {
    if (this.state.isDirty) {
      this.setState(prevState => ({
        ...prevState,
        showCancelModal: true,
      }))
    } else {
      window.history.back()
    }
  };

  // reset app
  onCancelClick = () => {
    this.setState(prevState => ({
      ...prevState,
      isDirty: false,
      showCancelModal: false,
    }))
    window.history.back()
  };

  onSpeciesChangeClick = () => {
    const initialState = new NewAnimalState()
    this.setState(
      prevState => ({
        ...initialState,
        isLoading: false,
        selectedOption: prevState.selectedOption,
        speciesList: [...prevState.speciesList],
        accountList: [...prevState.accountList],
        institutionList: [...prevState.institutionList],
        dietList: [...prevState.dietList],
        bdStatusList: [...prevState.bdStatusList],
        summaryData: [...prevState.summaryData],
        acquisitionTypeList: [...prevState.acquisitionTypeList],
        newAnimalData: {
          ...initialState.newAnimalData,
          species: this.selectedSpecies,
          selectedOption: prevState.newAnimalData.selectedOption,
        },
      }),
      this.loadListsForSpecies(this.selectedSpecies)
    )
  };

  // dismiss modals
  onCloseClick = () => {
    this.setState(prevState => ({
      ...prevState,
      showCancelModal: false,
      showSaveModal: false,
      showSpeciesChangeModal: false,
    }))
  };

  print = id => {
    const reportPath = getReportPath('BirthRecord')
    const fullPath = `${reportPath}&rc:Parameters=Collapsed&TargetID=${id}` // &rs:Format=PDF // uncomment to print to PDF

    const left = window.screenX + 20

    window.open(
      fullPath,
      '_blank',
      `location=yes,height=850,width=768,status=yes, left=${left}`
    )
  };

  render() {
    // allow debug mode to be triggered for running test suite
    this.debug = this.props.debug !== undefined ? this.props.debug : constants.debug

    const { isLoading } = this.state

    if (isLoading) {
      return <LoadingSpinner msg="Loading lookup tables..." />
    }

    return (
      <div>
        <div className="split-panel">
          <div className="parent-panel">
            <div
              className="panel-heading"
              disabled={ this.state.currentPanel !== 1 }
            >
              <p>Species and Acquisition Type</p>
            </div>
            <div
              className="species-panel"
              disabled={ this.state.currentPanel !== 1 }
            >
              <SpeciesPanel
                disabled={ this.state.currentPanel !== 1 }
                handleAcquisitionOptionChange={
                  this.handleAcquisitionOptionChange
                }
                handleSpeciesChange={ this.handleSpeciesChange }
                newAnimalData={ this.state.newAnimalData }
                selectedOption={ this.state.selectedOption }
                speciesList={ this.state.speciesList }
              />
            </div>

            { this.state.currentPanel === 1 && (
              <div className="fade-in">
                <div
                  className="panel-heading"
                  disabled={ this.disableFirstPanel() }
                >
                  <p>Acquisition</p>
                </div>
                <div
                  className="wizard-panel"
                  disabled={ this.disableFirstPanel() }
                >
                  <AcquisitionPanel
                    acquisitionTypeList={
                      this.state.acquisitionTypeList
                    }
                    disabled={ this.disableFirstPanel() }
                    handleDataChange={ this.handleDataChange }
                    newAnimalData={ this.state.newAnimalData }
                    preventNext={ this.preventNext }
                  />
                </div>
              </div>
            ) }

            { this.state.currentPanel === 2 && (
              <div className="fade-in">
                <div
                  className="panel-heading"
                  disabled={ this.disablePanels() }
                >
                  <p>Demographics</p>
                </div>
                <div
                  className="wizard-panel"
                  disabled={ this.disablePanels() }
                >
                  <DemographicsPanel
                    bdStatusList={ this.state.bdStatusList }
                    disabled={ this.disablePanels() }
                    handleDataChange={ this.handleDataChange }
                    newAnimalData={ this.state.newAnimalData }
                    potentialDamList={
                      this.state.potentialDamList
                    }
                    potentialSireList={
                      this.state.potentialSireList
                    }
                    preventNext={ this.preventNext }
                  />
                </div>
              </div>
            ) }

            { this.state.currentPanel === 3 && (
              <div className="fade-in">
                <div
                  className="panel-heading"
                  disabled={ this.disablePanels() }
                >
                  <p>Location</p>
                </div>
                <div
                  className="wizard-panel"
                  disabled={ this.disablePanels() }
                >
                  <LocationPanel
                    disabled={ this.disablePanels() }
                    handleDataChange={ this.handleDataChange }
                    handleError={ this.handleError }
                    locationList={ this.state.locationList }
                    newAnimalData={ this.state.newAnimalData }
                    preventNext={ this.preventNext }
                  />
                </div>
              </div>
            ) }

            { this.state.currentPanel === 4 && (
              <div className="fade-in">
                <div
                  className="panel-heading"
                  disabled={ this.disablePanels() }
                >
                  <p>Account, Colony, and Ownership</p>
                </div>
                <div
                  className="wizard-panel"
                  disabled={ this.disablePanels() }
                >
                  <AccountPanel
                    accountList={ this.state.accountList }
                    colonyList={ this.state.colonyList }
                    disabled={ this.disablePanels() }
                    handleDataChange={ this.handleDataChange }
                    iacucList={ this.state.iacucList }
                    institutionList={
                      this.state.institutionList
                    }
                    newAnimalData={ this.state.newAnimalData }
                    pedigreeList={ this.state.pedigreeList }
                    preventNext={ this.preventNext }
                  />
                </div>
              </div>
            ) }

            { this.state.currentPanel === 5 && (
              <div className="fade-in">
                <div
                  className="panel-heading"
                  disabled={ this.disablePanels() }
                >
                  <p>Diet</p>
                </div>
                <div
                  className="wizard-panel"
                  disabled={ this.disablePanels() }
                >
                  <DietPanel
                    dietList={ this.state.dietList }
                    disabled={ this.disablePanels() }
                    handleDataChange={ this.handleDataChange }
                    newAnimalData={ this.state.newAnimalData }
                    preventNext={ this.preventNext }
                  />
                </div>
              </div>
            ) }

            { this.state.errorMessage && (
              <InfoPanel
                errorMessages={
                  this.state.errorMessage && [
                    {
                      propTest: true,
                      colName: this.state.errorMessage,
                    },
                  ]
                }
              />
            ) }

            <div>
              <Pager className="pager-container">
                <Pager.Item
                  disabled={
                    this.state.currentPanel <= 1
                    || this.state.hasError
                  }
                  onClick={ this.handlePrevious }
                  previous
                >
                  &larr; Previous Page
                </Pager.Item>
                { this.state.currentPanel !== this.numPanels && (
                  <Pager.Item
                    disabled={
                      this.state.currentPanel
                      >= this.numPanels
                      || this.state.hasError
                      || this.state.preventNext
                    }
                    next
                    onClick={ this.handleNext }
                  >
                    Next Page &rarr;
                  </Pager.Item>
                ) }
                <Pager.Item
                  disabled={ false }
                  next={ false }
                  onClick={ this.handleCancel }
                >
                  Cancel
                </Pager.Item>
                { this.state.currentPanel === this.numPanels && (
                  <Pager.Item
                    disabled={
                      this.state.currentPanel
                      !== this.numPanels
                      || this.state.hasError
                      || this.state.preventNext
                    }
                    next
                    onClick={ this.handleSave }
                  >
                    Save
                  </Pager.Item>
                ) }
              </Pager>
            </div>
          </div>

          <div className="right-panel">
            <div>
              <div className="panel-heading">
                <p>New Animals (Saved)</p>
              </div>
              <div className="wizard-right">
                <SummaryGridPanel
                  print={ this.print }
                  summaryData={ this.state.summaryData }
                />
              </div>
            </div>
          </div>
        </div>

        <div>
          {/* Save Modal */ }
          <SaveModal
            newAnimalData={ this.state.newAnimalData }
            onCloseClick={ this.onCloseClick }
            onSaveClick={ this.onSaveClick }
            show={ this.state.showSaveModal }
          />
          {/* Cancel Modal */ }
          <CancelChangeModal
            message="If you cancel now, you will lose unsaved changes. Are you sure you want to cancel?"
            noClick={ this.onCloseClick }
            show={ this.state.showCancelModal }
            title="Cancel changes?"
            yesClick={ this.onCancelClick }
          />
          {/* Species Change Modal */ }
          <CancelChangeModal
            message="If you change species now, you will lose your current changes. Are you sure you want to change species?"
            noClick={ this.onCloseClick }
            show={ this.state.showSpeciesChangeModal }
            title="Changes Species?"
            yesClick={ this.onSpeciesChangeClick }
          />
        </div>
      </div>
    )
  }
}
