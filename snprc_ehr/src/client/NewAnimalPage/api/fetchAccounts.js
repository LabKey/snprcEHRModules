import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Account.value, label: data.DisplayValue.value }
    })
}

const fetchAccounts = () => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'AccountLookup',
            columns: ['Account', 'DisplayValue'],
            sort: 'Account'
        }).then(({ rows }) => {
            const parsedRows = parse(rows)
            resolve(parsedRows)
        }).catch(error => {
            console.log('error', error)
            reject(error)
        })
    })
}
export default fetchAccounts
