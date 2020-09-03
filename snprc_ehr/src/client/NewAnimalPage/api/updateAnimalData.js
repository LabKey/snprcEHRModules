import { Ajax, Utils, ActionURL } from '@labkey/api'

const convertToJson = newAnimalData => {
    const jsonData = {
        birthDate: newAnimalData.birthDate.date.toString(),
        birthCode: newAnimalData.bdStatus.value,
        acquisitionType: newAnimalData.acquisitionType.value,
        acqDate: newAnimalData.acqDate.date.toString(),
        gender: newAnimalData.gender.value,
        species: newAnimalData.species.value,
        animalAccount: newAnimalData.animalAccount.value,
        ownerInstitution: newAnimalData.ownerInstitution.value,
        responsibleInstitution: newAnimalData.responsibleInstitution.value,
        room: newAnimalData.room.rowId,
        diet: newAnimalData.diet.value,
        ...(newAnimalData.cage && { cage: newAnimalData.cage.value }),
        ...(newAnimalData.pedigree && { pedigree: newAnimalData.pedigree.value }),
        ...(newAnimalData.iacuc && { iacuc: newAnimalData.iacuc.value }),
        ...(newAnimalData.colony && { colony: newAnimalData.colony.value }),
        ...(newAnimalData.sire && { sire: newAnimalData.sire.value }),
        ...(newAnimalData.dam && { dam: newAnimalData.dam.value })
    }
    return jsonData
}

export const uploadAnimalData = (newAnimalData, numAnimals) => {
    const isMultipleSequenceRequest = (numAnimals > 1)
    const url = `${ActionURL.buildURL('snprc_ehr', 'UpdateAnimalData.api')}?isMultipleSequenceRequest=${isMultipleSequenceRequest}`
    return new Promise((resolve, reject) => {
        Ajax.request({
            method: 'POST',
            url,
            jsonData: convertToJson(newAnimalData),
            success: Utils.getCallbackWrapper(data => {
                if (data.success === false)
                    reject( {exception: data.message} )
                else
                    resolve(data)
            }),
            failure: Utils.getCallbackWrapper(error => {
                reject(error)
            })
        })
    })
}
