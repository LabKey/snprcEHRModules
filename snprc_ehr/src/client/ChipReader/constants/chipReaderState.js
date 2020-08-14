import moment from 'moment'
import defaults from './index'

const ChipReaderState = () => {
    
    return ({
        port: undefined,
        serialOptions: [],
        connection: undefined,
        chipData: {chipId: undefined, animalId: undefined, temperature: undefined},
        summaryData: [],
        isLoading: true,
        hasError: false,
        showCancelModal: false,
        errorMessage: undefined
    })
}

export default ChipReaderState
