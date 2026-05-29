/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import constants from '../constants'

export const isNonPrimate = species => {
    return species && constants.nonPrimateList.includes(species.value)
}
