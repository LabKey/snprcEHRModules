import { readWithTimeout, read } from './serialService'
import constants from '../constants'

// convert temperature to fahrenheit - return -1 if NaN
const celsiusToFahrenheit = c => {
    // f = 1.8 * c + 32
    const f = Number.isNaN(Number.parseFloat(c)) ? -1 : 1.8 * Number.parseFloat(c) + 32
    return f.toFixed(1)
}

export const getChipData = async connection => {
    let data
    let dataArr = []
    let dataObj

    // read serial port with a timeout
    data = await readWithTimeout(constants.readTimeout, read(connection)
        .catch(error => {
            console.log(`readWithTimeout error: ${error}`)
            throw error
        }))

    if (data) {
        // process chip data
        if (data.indexOf('XX') === -1) { // clean queue
            if (data.substring(0, 7) === '1000000') { // find 7 digit BIOMARK prefix
                data = data.substring(10, data.length) // remove 10 digit prefix
            } else if (data.slice(-1) === ',') { // remove trailing comma from certain UID chips
                data = data.substring(0, data.length - 1)
            }

            dataArr = data.split(',')
            const len = dataArr.length

            dataObj = {
                chipId: dataArr[0].trim(),
                ...(len === 1 && { animalId: undefined, temperature: undefined }),
                ...(len === 2 && { animalId: undefined, temperature: celsiusToFahrenheit(dataArr[1].trim()) }),
                ...(len === 3 && { animalId: dataArr[1].trim(), temperature: celsiusToFahrenheit(dataArr[2].trim()) })
            }
        }
    }

    return dataObj
}
