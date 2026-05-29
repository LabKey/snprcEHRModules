/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
