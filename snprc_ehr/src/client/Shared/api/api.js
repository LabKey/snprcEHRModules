import { Query } from '@labkey/api'

export const request = ({ schemaName, queryName, viewName = '', sort = '', columns = [], filterArray = [] }) => {
    return new Promise((resolve, reject) => {
        const success = response => {
            resolve(response)
        }
        const failure = error => {
            reject(error)
        }
        Query.selectRows({
            requiredVersion: 19.2,
            schemaName,
            queryName,
            viewName,
            sort,
            columns,
            success,
            failure,
            filterArray
        })
    })
}

export const executeSql = ({ schemaName, sql, sort = '' }) => {
    return new Promise((resolve, reject) => {
        const success = response => {
            resolve(response)
        }
        const failure = error => {
            reject(error)
        }
        Query.executeSql({
            requiredVersion: 19.2,
            schemaName,
            sql,
            sort,
            success,
            failure
        })
    })
}
