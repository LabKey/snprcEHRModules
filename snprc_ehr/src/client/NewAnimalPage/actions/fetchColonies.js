import { request } from '../../utils/actions/api';

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
                LABKEY.Filter.create('Species', species, LABKEY.Filter.Types.EQUAL),
                LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.MISSING)
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