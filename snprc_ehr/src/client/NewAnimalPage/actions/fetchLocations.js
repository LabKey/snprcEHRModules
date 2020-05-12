import { request } from '../../utils/actions';

const parse = (rawSpecies) => {
    return rawSpecies.map((object, key) => {
        const { data } = object
        return { id: key, value: data.room.value, label: data.room.value, arcSpeciesCode: data.species.value, maxCages: data.maxCages.value }
    })
}

const fetchLocations = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'ActiveLocationsAll',
            columns: ['species', 'room', 'maxCages'],
            sort: "room",
            filterArray: [
                LABKEY.Filter.create('species', species, LABKEY.Filter.Types.EQUAL)
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
