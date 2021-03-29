import moment from 'moment'
import { Filter } from '@labkey/api'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key,
            value: data.Sire.value,
            label: data.Sire.value,
            ArcSpeciesCode: data.ArcSpeciesCode.value,
            Age: data.Age.value }
    })
}

const fetchPotentialSires = (species, birthdate, selectedOption) => {
    return new Promise((resolve, reject) => {
        request({
            parameters: {'birthdateParm': birthdate, 'selectedOptionParm': selectedOption},
            schemaName: 'study',
            queryName: 'PotentialSires',
            columns: ['Sire', 'ArcSpeciesCode', 'Age'],
            sort: 'Sire',
            filterArray: [
                Filter.create('ArcSpeciesCode', species, Filter.Types.EQUAL)
            ]
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('error', error)
        })
    })
}
export default fetchPotentialSires
