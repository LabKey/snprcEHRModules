import constants from '../constants'

export const isNonPrimate = species => {
    return species && constants.nonPrimateList.includes(species.value)
}
