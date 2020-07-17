/* eslint-disable no-unused-vars, camelcase */

import { NewAnimalData } from '../../../BirthRecordReport/tests/fixtures/apiTestData'
import {
    CurrentSpeciesLookup, AccountLookup, validInstitutions, ValidDiet, AcquisitionTypesLookup,
    valid_bd_status, PotentialDams, PotentialSires, ActiveLocationsAll, colonyGroups,
    ProtocolLookup, pedigreeGroups
} from '../../../NewAnimalPage/tests/fixtures/apiTestData'

export const request = ({ schemaName, queryName, viewName = '', sort = '', columns = [], filterArray = [] }) => {
    // console.log(`loading list: ${queryName}`);
    return new Promise(resolve => {
        switch (queryName) {
            case 'CurrentSpeciesLookup':
                resolve(CurrentSpeciesLookup)
                break
            case 'AccountLookup':
                resolve(AccountLookup)
                break
            case 'validInstitutions':
                resolve(validInstitutions)
                break
            case 'ValidDiet':
                resolve(ValidDiet)
                break
            case 'AcquisitionTypesLookup':
                resolve(AcquisitionTypesLookup)
                break
            case 'PotentialDams':
                resolve(PotentialDams)
                break
            case 'PotentialSires':
                resolve(PotentialSires)
                break
            case 'colonyGroups':
                resolve(colonyGroups)
                break
            case 'ProtocolLookup':
                resolve(ProtocolLookup)
                break
            case 'pedigreeGroups':
                resolve(pedigreeGroups)
                break
            case 'valid_bd_status':
                resolve(valid_bd_status)
                break
            case 'NewAnimalData':
                resolve(NewAnimalData)
                break
            default:
                break
        }
    })
}

export const executeSql = ({ schemaName, sql, sort = '' }) => {
    return new Promise(resolve => {
        if (sql.indexOf('FROM ehr_lookups.rooms') > 0) {
            resolve(ActiveLocationsAll)
        }
    })
}
