import moment from 'moment';

const NewAnimalState = () => {

    return  ({
        currentPanel: 1,
        selectedOption: undefined,
        newAnimalData: {
            id: undefined,
            birthDate: { date: moment() },
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
        saveOk: true,
        showSaveModal: false,
        showCancelModal: false,
        showSpeciesChangeModal: false

    });
}

export default NewAnimalState;