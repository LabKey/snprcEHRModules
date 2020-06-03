import moment from 'moment';

export const isBirthdateValid = (birthdate, acqDate) => {
    return (
        moment(birthdate).isSameOrBefore(moment(acqDate))
    );
}

export const validateCage = (room, cage) => {
    let hasError = false;

    if (room && room.maxCages) {

        hasError = cage !== "" && (cage > room.maxCages || cage < 1);
    }

    return hasError ? `Cage # must be between 1 and ${room.maxCages} in Location ${room.value}` : undefined;

}

