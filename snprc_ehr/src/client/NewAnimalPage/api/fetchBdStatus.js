import { request } from './api';

const parse = rows => {
    return rows.map(( { data }, key) => {
        return { id: key, value: data.value.value, label: data.description.value }
    })
}

const fetchBdStatus = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'valid_bd_status',
            columns: ['value', 'description'],
            sort: "value"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchBdStatus;