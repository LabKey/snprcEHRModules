import { Filter } from '@labkey/api'
import { request } from './api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key,
            value: data.AcqCode.value,
            label: data.DisplayValue.value,
            Category: data.Category.value,
            SortOrder: data.SortOrder.value }
    })
}

const fetchAcquisitionTypes = type => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'ehr_lookups',
            queryName: 'AcquisitionTypesLookup',
            columns: ['AcqCode', 'DisplayValue', 'Category', 'SortOrder'],
            sort: 'SortOrder',
            filterArray: [
                Filter.create('Category', type, Filter.Types.EQUAL)
            ]
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('error', error)
        })
    })
}
export default fetchAcquisitionTypes
