import { request } from '../../utils/actions/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.room.value, label: data.room.value, arcSpeciesCode: data.species.value, maxCages: data.maxCages.value }
    })
}

const fetchLocations = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'ActiveLocationsAll',
            columns: ['species', 'room', 'maxCages'],
            sort: "-species, room",
            filterArray: [
                LABKEY.Filter.create('species', species, LABKEY.Filter.Types.EQUAL)
                //LABKEY.Filter.create('species', `${species}; ''`, LABKEY.Filter.Types.IN)
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
