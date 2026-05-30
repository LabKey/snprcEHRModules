/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import { Query } from '@labkey/api'

export const request = ({ schemaName, queryName, parameters = {}, viewName = '', sort = '', columns = [], filterArray = [] }) => {
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
            parameters,
            success,
            failure,
            filterArray
        })
    })
}

export const executeSql = ({ schemaName, sql, parameters = {}, sort = '' }) => {
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
            parameters,
            success,
            failure
        })
    })
}
