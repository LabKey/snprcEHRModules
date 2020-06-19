import { request } from './api';
import { Filter } from '@labkey/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Iacuc.value, label: data.DisplayValue.value, species: data.Species.value, maxAnimals: data.MaxAnimals.value }
    })
}

const fetchProtocols = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'ehr',
            queryName: 'ProtocolLookup',
            columns: ['Iacuc', 'DisplayValue', 'Species', 'MaxAnimals'],
            filterArray: [
                Filter.create('Species', species, Filter.Types.EQUAL),
                Filter.create('EndDate', null, Filter.Types.MISSING)
            ],
            sort: "Iacuc"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchProtocols;