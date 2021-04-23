import { Filter } from '@labkey/api'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key,
            value: data.Dam.value,
            label: data.Dam.value,
            ArcSpeciesCode: data.ArcSpeciesCode.value,
            Age: data.Age.value }
    })
}

const fetchPotentialDams = (species, birthdate, selectedOption) => {
    return new Promise((resolve, reject) => {
        request({
            parameters: { birthdateParm: birthdate, selectedOptionParm: selectedOption },
            schemaName: 'study',
            queryName: 'PotentialDams',
            columns: ['Dam', 'ArcSpeciesCode', 'Age'],
            sort: 'Dam',
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
export default fetchPotentialDams
