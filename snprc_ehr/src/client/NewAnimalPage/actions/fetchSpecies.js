import { request } from '../../utils/actions/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.SpeciesCode.value, label: data.DisplayColumn.value, arcSpeciesCode: data.arcSpeciesCode.value }
    })
}

const fetchSpecies = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'CurrentSpeciesLookup',
            columns: ['SpeciesCode', 'DisplayColumn', 'arcSpeciesCode']
        }).then(({ rows }) => {
            resolve(parse(rows));
        }).catch((error) => {
            reject(error);
            console.log('error', error);
        })
    });
}
export default fetchSpecies;
