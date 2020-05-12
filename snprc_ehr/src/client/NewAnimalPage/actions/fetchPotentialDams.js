import { request } from '../../utils/actions';

const parse = (rawTypes) => {
    return rawTypes.map((object, key) => {
        const { data } = object
        return { id: key, value: data.Dam.value, label: data.Dam.value, 
                 ArcSpeciesCode: data.ArcSpeciesCode.value, Age: data.Age.value }
    })
}

const fetchPotentialDams = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'study',
            queryName: 'PotentialDams',
            columns: ['Dam', 'ArcSpeciesCode', 'Age'],
            sort: "SortOrder",
            filterArray: [
                LABKEY.Filter.create('ArcSpeciesCode', species, LABKEY.Filter.Types.EQUAL)
              ]
        }).then(({ rows }) => {
            resolve(parse(rows));
        }).catch((error) => {
            reject(error);
            console.log('error', error);
        })
    });
}
export default fetchPotentialDams;
