import { request } from './api';
import { Filter } from '@labkey/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.room.value, label: data.room.value, arcSpeciesCode: data.species.value, maxCages: data.maxCages.value, rowId: data.rowId.value }
    })
}

const fetchLocations = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'ActiveLocationsAll',
            columns: ['species', 'room', 'maxCages', 'rowId'],
            sort: "-species, room",
            filterArray: [
                //Filter.create('species', species, Filter.Types.EQUAL)
                Filter.create('species', `${species}; null`, Filter.Types.IN)
            ]
        }).then(({ rows }) => {
            resolve(parse(rows));
        }).catch((error) => {
            reject(error);
            console.log('error', error);
        })
    });
}
export default fetchLocations;
