/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
