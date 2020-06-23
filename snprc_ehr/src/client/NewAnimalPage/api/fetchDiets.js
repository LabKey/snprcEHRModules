import { request } from './api';
import { Filter } from '@labkey/api';

const parse = rows => {
    return rows.map(( { data }, key) => {
        return { id: key, value: data.SnomedCode.value, label: data.Diet.value, species: data.ARCSpeciesCode.value}
    })
}

const fetchDiets = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'ValidDiet',
            columns: ['SnomedCode', 'Diet', 'ARCSpeciesCode'],
            filterArray: [
                //Filter.create('ARCSpeciesCode', species, Filter.Types.EQUAL),
                Filter.create('StopDate', null, Filter.Types.MISSING)
            ],
            sort: "Diet"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchDiets;