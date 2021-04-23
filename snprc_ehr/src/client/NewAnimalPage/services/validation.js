import moment from 'moment'

export const isBirthdateValid = (birthdate, acqDate) => {
    return (
        birthdate.isSameOrBefore(acqDate)
    )
}

export const isFutureDate = date => {
    return (
        date.isSameOrBefore(moment())
    )
}

export const validateCage = (room, cage) => {
    let hasError = false

    if (room && room.maxCages) {
        hasError = cage !== '' && (cage > room.maxCages || cage < 1)
    }

    return hasError ? `Cage # must be between 1 and ${room.maxCages} in Location ${room.value}` : undefined
}

export const validateNumAnimals = numAnimals => {
    let hasError = false

    if (numAnimals) {
        hasError = numAnimals < 1 || numAnimals > 100
    }

    return hasError ? 'Number of Animals must be between 1 and 100' : undefined
}
