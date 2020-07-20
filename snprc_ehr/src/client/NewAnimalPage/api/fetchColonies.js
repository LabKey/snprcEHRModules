import { executeSql } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Code.value, label: data.Name.value, species: data.Species.value, Category: data.Category.value }
    })
}

const fetchColonies = species => {
    const sql = `SELECT c.Code,
                    c.Name,
                    c.Species,
                    c.Category
                FROM snprc_ehr.colonyGroups AS c
                WHERE c.enddate is NULL
                AND (c.Species = '${species}' OR c.Species IS NULL)`

    return new Promise((resolve, reject) => {
        if (!species || species.length !== 2) reject(new Error('Invalid species format detected'))

        executeSql({
            schemaName: 'snprc_ehr',
            sql,
            sort: '-Species, Name'
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('Error', error)
        })
    })

}

export default fetchColonies
