import { Filter } from '@labkey/api'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Iacuc.value, label: data.DisplayValue.value, species: data.Species.value, maxAnimals: data.MaxAnimals.value }
    })
}

const fetchProtocols = species => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'ehr',
            queryName: 'ProtocolLookup',
            columns: ['Iacuc', 'DisplayValue', 'Species', 'MaxAnimals'],
            filterArray: [
                Filter.create('Species', species, Filter.Types.EQUAL),
                Filter.create('EndDate', null, Filter.Types.MISSING),
                Filter.create('ApprovalDate', null, Filter.Types.NOT_MISSING)
            ],
            sort: 'ProjectType, SequenceNumber'
        }).then(({ rows }) => {
            const parsedRows = parse(rows)
            resolve(parsedRows)
        }).catch(error => {
            console.log('error', error)
            reject(error)
        })
    })
}
export default fetchProtocols
