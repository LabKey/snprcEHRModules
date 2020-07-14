import { Filter } from '@labkey/api'
import moment from 'moment'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }) => {
        return {
            Id: data.Id.value,
            value: data.Id.value,
            label: `Id: ${data.Id.value} - ${data.gender.displayValue} - Birth Date: ${moment(data.BirthDate.value).format('MM/DD/YYYY h:mm A')} `,
            BirthDate: data.BirthDate.value,
            BirthCode: data.BirthCode.value,
            AcquisitionType: data.AcquisitionType.value,
            AcqDate: data.AcqDate.value,
            gender: data.gender.value,
            sire: data.sire.value,
            dam: data.dam.value,
            species: data.species.value,
            Colony: data.Colony.value,
            AnimalAccount: data.AnimalAccount.value,
            OwnerInstitution: data.OwnerInstitution.value,
            ResponsibleInstitution: data.ResponsibleInstitution.value,
            room: data.room.value,
            Cage: data.Cage.value,
            Diet: data.Diet.value,
            pedigree: data.pedigree.value,
            IACUC: data.IACUC.value
        }
    })
}

const fetchNewAnimalData = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'NewAnimalData',
            columns:
                [
                    'Id',
                    'BirthDate',
                    'BirthCode',
                    'AcquisitionType',
                    'AcqDate',
                    'gender',
                    'sire',
                    'Dam',
                    'Species',
                    'Colony',
                    'AnimalAccount',
                    'OwnerInstitution',
                    'ResponsibleInstitution',
                    'room',
                    'Cage',
                    'Diet',
                    'pedigree',
                    'IACUC'
                ],

            sort: 'Id',
            filterArray: [
                Filter.create('AcquisitionType/category', 'Birth', Filter.Types.EQUAL)
            ]
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('error', error)
        })
    })
}
export default fetchNewAnimalData
