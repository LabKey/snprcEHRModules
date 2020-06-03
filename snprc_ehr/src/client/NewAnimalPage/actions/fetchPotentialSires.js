import { request } from '../../utils/actions/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Sire.value, label: data.Sire.value, 
                 ArcSpeciesCode: data.ArcSpeciesCode.value, Age: data.Age.value }
    })
}

const fetchPotentialSires = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'study',
            queryName: 'PotentialSires',
            columns: ['Sire', 'ArcSpeciesCode', 'Age'],
            sort: "Sire",
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
export default fetchPotentialSires;
