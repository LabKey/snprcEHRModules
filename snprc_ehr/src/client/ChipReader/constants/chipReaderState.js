const ChipReaderState = () => {
    return ({
        port: undefined,
        serialOptions: [],
        connection: undefined,
        chipData: { chipId: undefined, animalId: undefined, temperature: undefined, time: undefined },
        summaryData: [],
        isLoading: true,
        hasError: false,
        showCancelModal: false,
        errorMessage: undefined
    })
}

export default ChipReaderState
