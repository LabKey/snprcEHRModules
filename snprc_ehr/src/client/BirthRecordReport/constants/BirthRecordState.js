const birthRecordState = () => {
    return ({
        isDirty: false,
        summaryData: [],
        animalList: [],
        isLoading: true,
        selectedAnimal: undefined,
        errorMessage: undefined
    })
}

export default birthRecordState
