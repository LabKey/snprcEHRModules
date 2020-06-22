import { Ajax, Utils, ActionURL } from '@labkey/api';

export const uploadAnimalData = jsonData => {
  const url = ActionURL.buildURL('snprc_ehr', 'UpdateAnimalData.api');
  return new Promise((resolve, reject) => {
    Ajax.request({
      method: 'POST',
      url: url,
      jsonData: jsonData,
      success: Utils.getCallbackWrapper((data) => {
        resolve(data);
      }),
      failure: Utils.getCallbackWrapper((error) => {
        reject(error);
      })
    })
  })
}

export const formatDataForUpload = newAnimalData => {
  
  const jsonData = {
      "birthDate": `${newAnimalData.birthDate.date.toString()}`,
      "acquisitionType": `${newAnimalData.acquisitionType.value}`,
      "acqDate": `${newAnimalData.acqDate.date.toString()}`,
      "gender": `${newAnimalData.gender.value}`,
      "species": `${newAnimalData.species.value}`,
      "animalAccount": newAnimalData.animalAccount.id,
      "ownerInstitution": `${newAnimalData.ownerInstitution.value}`,
      "responsibleInstitution": `${newAnimalData.responsibleInstitution.value}`,
      "room": newAnimalData.room.rowId,
      "diet": `${newAnimalData.diet.id}`,
      ...(newAnimalData.cage && { "cage": newAnimalData.cage.value }),
      ...(newAnimalData.pedigree && { "pedigree": newAnimalData.pedigree.value }),
      ...(newAnimalData.iacuc  && { "iacuc":  newAnimalData.iacuc.id }),
      ...(newAnimalData.colony && { "colony": newAnimalData.colony.value }),
      ...(newAnimalData.sire && { "sire": newAnimalData.sire.value }),
      ...(newAnimalData.dam && { "dam":  newAnimalData.dam.value })
  };
  return jsonData;
}
