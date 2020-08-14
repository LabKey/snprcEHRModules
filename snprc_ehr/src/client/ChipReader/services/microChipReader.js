import { read } from './serialService'

export const  getChipData = async (connection) => {

    let data, filteredData

    data = await read(connection).catch(error => {
        throw error
    })


    if ( data ) {
        // process chip data
        if (data.indexOf('XXX') === -1 ) {

            filteredData = data === 'XXXXXXXXXX\r' ? '' : data.replace(/\r/g,'')
            //filteredData = data.replace(/[X]/g,'')
        }

    } 
    return filteredData
    
}