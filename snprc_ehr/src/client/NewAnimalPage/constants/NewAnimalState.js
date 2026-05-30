/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import moment from 'moment'
import defaults from './index'

const NewAnimalState = () => {
    const { defaultInstitution } = defaults

    return ({
        currentPanel: 1,
        selectedOption: undefined,
        isDirty: false,
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
            ownerInstitution: defaultInstitution,
            responsibleInstitution: defaultInstitution,
            room: undefined,
            cage: { value: undefined },
            diet: undefined,
            pedigree: undefined,
            iacuc: undefined,
            sourceLocation: undefined,
            isNonPrimate: undefined
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
        sourceLocationList: [],
        isLoading: true,
        hasError: false,
        preventNext: true,
        showSaveModal: false,
        showCancelModal: false,
        showSpeciesChangeModal: false,
        errorMessage: undefined,
        numAnimals: undefined
    })
}

export default NewAnimalState
