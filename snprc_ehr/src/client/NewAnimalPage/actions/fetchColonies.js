import { request } from '../../utils/actions/api';
import { Filter } from '@labkey/api';

const parse = rows => {
    return rows.map(( { data }, key) => {
        return { id: key, value: data.Code.value, label: data.Name.value, species: data.Species.value, Category: data.Category.value }
    })
}

const fetchColonies = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'colonyGroups',
            columns: ['Code', 'Name', 'Species', 'Category'],
            filterArray: [
                Filter.create('Species', species, Filter.Types.EQUAL),
                Filter.create('enddate', null, Filter.Types.MISSING)
            ],
            sort: "Name"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchColonies;