import { request } from '../../utils/actions';

const parse = (rawTypes) => {
    return rawTypes.map((object, key) => {
        const { data } = object
        return { id: key, value: data.AcqCode.value, label: data.DisplayValue.value, 
                 Category: data.Category.value, SortOrder: data.SortOrder.value }
    })
}

const fetchAcquisitionTypes = (type) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'ehr_lookups',
            queryName: 'AcquisitionTypesLookup',
            columns: ['AcqCode', 'DisplayValue', 'Category','SortOrder'],
            sort: "SortOrder",
            filterArray: [
                LABKEY.Filter.create('Category', type, LABKEY.Filter.Types.EQUAL)
              ]
        }).then(({ rows }) => {
            resolve(parse(rows));
        }).catch((error) => {
            reject(error);
            console.log('error', error);
        })
    });
}
export default fetchAcquisitionTypes;
