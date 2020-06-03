import { request } from '../../utils/actions/api';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.institution_id.value, 
            label: (data.short_name.value + ' - ' + data.institution_name.value) }
    })
}

const fetchInstitutions = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'validInstitutions',
            columns: ['institution_id', 'institution_name', 'short_name'],
            sort: "institution_id"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchInstitutions;