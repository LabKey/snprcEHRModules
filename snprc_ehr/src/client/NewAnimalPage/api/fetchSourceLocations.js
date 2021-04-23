import { executeSql } from '../../Shared/api/api'

const parse = rows => {
    return rows.map(({ data }, key) => {
        let label = `${data.code.value} - ${data.meaning.value}`
        label += (data.SourceCity.value != null ? `, ${data.SourceCity.value}` : '')
        label += (data.SourceState.value != null ? `, ${data.SourceState.value}` : '')
        label += (data.SourceCountry.value != null ? `, ${data.SourceCountry.value}` : '')

        return { id: key,
            value: data.code.value,
            label,
            rowId: data.rowid.value }
    })
}

const fetchSourceLocations = () => {
    const sql = `SELECT 
                    s.rowid,
                    s.code,
                    s.description,
                    s.meaning,
                    s.SourceCity,
                    s.SourceState,
                    s.SourceCountry
                FROM ehr_lookups.source as s
                INNER JOIN ehr_lookups.rooms r on s.code = r.room
                WHERE r.dateDisabled is NULL `

    return new Promise((resolve, reject) => {
        executeSql({
            schemaName: 'ehr_lookups',
            sql,
            sort: 'code'
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('Error', error)
        })
    })
}
export default fetchSourceLocations
