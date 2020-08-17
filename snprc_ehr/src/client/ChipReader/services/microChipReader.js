import { readWithTimeout, read } from './serialService'
import constants from '../constants/index'

export const getChipData = async (connection) => {

    let data
    let dataArr = []
    let dataObj

    // read serial port with a 2 second timeout
    data = await readWithTimeout(2000, read(connection)
    .catch(error => {
        throw error 
    }))


    if (data) {
        // process chip data
        if (data.indexOf('XX') === -1) {  // clean queue

            data = data === 'XXXXXXXXXX\r' ? '' : data.replace(/\r/g, '')
            dataArr = data.split(",")
            const len = dataArr.length

            dataObj = {
                chipId: dataArr[0].trim(),
                ...(len === 1 && { animalId: undefined, temperature: undefined }),
                ...(len === 2 && { animalId: undefined, temperature: dataArr[1].trim() }),
                ...(len === 3 && { animalId: dataArr[1].trim(), temperature: dataArr[2].trim() })
            }
        }
    }
    
    return dataObj
}