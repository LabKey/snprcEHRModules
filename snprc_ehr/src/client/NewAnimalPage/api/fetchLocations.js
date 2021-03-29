import { executeSql } from '../../Shared/api/api'
import constants from '../constants'

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.room.value, 
            label: `${data.room.value} - ${data.description.value}`, 
            arcSpeciesCode: data.species.value, maxCages: data.maxCages.value, 
            rowId: data.rowId.value }
    })
}

const fetchLocations = (species, acquisitionType) => {
    let sql = `SELECT h.species  AS species,
                    r.room     AS room,
                    r.maxCages AS maxCages,
                    r.rowId AS rowId,
                    r.building as description
            FROM ehr_lookups.rooms r
            LEFT OUTER JOIN (
                SELECT DISTINCT d.species.arc_species_code as species, d2.room AS room
                FROM study.housing AS d2
                INNER join study.demographics d on d2.id = d.id
            WHERE d2.enddate IS NULL
                 AND d2.qcstate.publicdata = true
            ) AS h ON r.room = h.room
            WHERE r.dateDisabled is NULL
                AND (h.species = '${species}' OR h.species is NULL)`

    const { offSiteAcqCodes } = constants
    if ( offSiteAcqCodes.split(',').filter(code => code == acquisitionType).length > 0 ) {
        sql = sql + ` AND CAST(r.room as FLOAT) >= 800.00`
    }
    else {
        sql = sql + ` AND CAST(r.room as FLOAT) BETWEEN 1.00 AND 799.99`
    }
    return new Promise((resolve, reject) => {
        if (!species || species.length !== 2) reject(new Error('Invalid species format detected'))

        executeSql({
            schemaName: 'snprc_ehr',
            sql,
            sort: '-species, room'
        }).then(({ rows }) => {
            resolve(parse(rows))
        }).catch(error => {
            reject(error)
            console.log('Error', error)
        })
    })
}
export default fetchLocations
