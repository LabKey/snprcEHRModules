import { read } from './serialService'

export const getChipData = async (connection) => {

    let data
    let dataArr = []
    let dataObj

    data = await read(connection).catch(error => {
        throw error
    })


    if (data) {
        // process chip data
        if (data.indexOf('XXX') === -1) {  // clean queue

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