import { executeSql } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { value: data.Id.value, url: data.Id.url }
    })
}

const fetchAnimalId = chipId => {
    const sql = `SELECT ih.Id AS Id
            FROM study.idHistory as ih
            WHERE ih.value = '${chipId}'`
                

    return new Promise((resolve, reject) => {
        //if (!species || species.length !== 2) reject(new Error('Invalid species format detected'))

        executeSql({
            schemaName: 'study',
            sql
        }).then(({ rows }) => {
            const parseRows = parse(rows)
            if (parseRows.length !== 1)
                throw new Error ("Animal not found")
            resolve(parseRows[0])
        }).catch(error => {
            reject(error)
            console.log('Error', error)
        })
    })
}
export default fetchAnimalId
