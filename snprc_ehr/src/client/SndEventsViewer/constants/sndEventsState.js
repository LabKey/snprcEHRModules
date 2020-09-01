import defaults from './index'

const SndEventsState = () => {

    return ({
        isDirty: false,
        summaryData: [],
        isLoading: true,
        hasError: false,
        showCancelModal: false,
        errorMessage: undefined
    })
}

export default SndEventsState
