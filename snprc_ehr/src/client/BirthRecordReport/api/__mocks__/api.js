/* eslint-disable no-unused-vars, camelcase */

import { NewAnimalData } from '../../tests/fixtures/apiTestData'

export const request = ({ schemaName, queryName, viewName = '', sort = '', columns = [], filterArray = [] }) => {
    // console.log(`loading list: ${queryName}`);
    return new Promise(resolve => {
        switch (queryName) {
        case 'NewAnimalData':
            resolve(NewAnimalData)
            break
        default:
            break
        }
    })
}
