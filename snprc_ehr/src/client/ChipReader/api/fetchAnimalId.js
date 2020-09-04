import { executeSql } from '../../Shared/api/api'
import moment from 'moment'

const parse = rows => {
    return rows.map(({ data }) => {
        return { value: data.Id.value, url: data.Id.url, location: data.location.value, time: moment() }
    })
}

const fetchAnimalId = chipId => {
    const parameters = {'chipId': chipId}
    const sql = 'PARAMETERS ( chipId VARCHAR DEFAULT NULL ) '
        .concat('SELECT ih.Id AS Id, ih.Id.curLocation.location as location ')
        .concat('FROM study.idHistory as ih ')
        .concat('WHERE ih.value = chipId')

    return new Promise((resolve, reject) => {

        executeSql({
            schemaName: 'study',
            sql,
            parameters
        }).then(({ rows }) => {
            const parseRows = parse(rows)
            if (parseRows.length !== 1)
                throw new Error ("Animal not found")
            resolve(parseRows[0])
        }).catch(error => {
            reject(error)
        })
    })
}
export default fetchAnimalId
