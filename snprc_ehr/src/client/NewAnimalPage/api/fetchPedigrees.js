/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import { Filter } from '@labkey/api'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Code.value, label: data.Name.value, species: data.Species.value, Category: data.Category.value }
    })
}

const fetchPedigrees = species => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'pedigreeGroups',
            columns: ['Code', 'Name', 'Species', 'Category'],
            filterArray: [
                Filter.create('Species', species, Filter.Types.EQUAL),
                Filter.create('enddate', null, Filter.Types.MISSING)
            ],
            sort: 'Name'
        }).then(({ rows }) => {
            const parsedRows = parse(rows)
            resolve(parsedRows)
        }).catch(error => {
            console.log('error', error)
            reject(error)
        })
    })
}
export default fetchPedigrees
