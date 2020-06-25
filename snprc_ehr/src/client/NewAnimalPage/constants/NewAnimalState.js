import moment from 'moment';

const NewAnimalState = () => {

    return  ({
        currentPanel: 1,
        selectedOption: undefined,
        newAnimalData: {
            selectedOption: undefined,
            id: undefined,
            birthDate: { date: moment() },
            bdStatus: undefined,
            acquisitionType: undefined,
            acqDate: { date: moment() },
            gender: undefined,
            sire: undefined,
            dam: undefined,
            species: undefined,
            colony: undefined,
            animalAccount: undefined,
            ownerInstitution: undefined,
            responsibleInstitution: undefined,
            room: undefined,
            cage: { value: undefined },
            diet: undefined,
            pedigree: undefined,
            iacuc: undefined
        },
        summaryData: [],
        speciesList: [],
        acquisitionTypeList: [],
        potentialDamList: [],
        potentialSireList: [],
        locationList: [],
        accountList: [],
        colonyList: [],
        dietList: [],
        institutionList: [],
        iacucList: [],
        pedigreeList: [],
        bdStatusList: [],
        isLoading: true,
        hasError: false,
        preventNext: true,
        saveOk: false,
        showSaveModal: false,
        showCancelModal: false,
        showSpeciesChangeModal: false,
        errorMessage: undefined
    });
}

export default NewAnimalState;
