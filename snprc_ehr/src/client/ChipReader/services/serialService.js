import constants from '../constants'

export const requestPort = async () => {
    return await navigator.serial.requestPort().catch ( error => {
        throw error
    })
}

export const setSerialOptions = (serialOptions, property, value) => {
    if (!serialOptions || !property || !value)
        throw new Error('setSerialOptions requires: serialOptions, property, value')

    if (constants.validSerialOptions.indexOf(property) === -1)
        throw new Error ('Invalid setSerialOptions Property')

    const newOptions = {
        ...serialOptions,
        [property]: value
    }

    return newOptions
  }

export const connect = async (port, serialOptions) => {
    if (!port || !serialOptions)
        throw new Error('Connection request requires port and serialOptions')

    
    await port.open( serialOptions ).catch( error => {
        throw new Error(`Port.open() error: ${error.message}`)
    })

    const connection = {
        port: port,
        serialOptions: serialOptions,
        reader: port.readable.getReader(),
        writer: port.writable.getWriter()
    }

    return connection
}

export const write = async (connection, text) => {
    if (!connection)
        throw new Error('Write requires a valid connection object')

    await connection.writer.write(text)
    await connection.writer.write('\r')
}

export const readWithTimeout = function (ms, reader) {

    let timerId = null;

    // Create a promise that rejects in the specified timeout period (ms)
    let timeout = new Promise((resolve, reject) => {
        timerId = setTimeout(() => {
            clearTimeout(timerId)
            reject(new Error (constants.timeOutErrorMessage))
        }, ms)
    })

    // Returns a race between our timeout and the passed in promise
    return Promise.race([
        reader.then(value => {
            clearTimeout(timerId)
            return value
        }),
        timeout
    ])
}

export const read = async (connection) => {
    if (!connection)
        throw new Error('Read requires a valid connection object')

    let data = ''


    while (true)  {
        let cr = false
        const { value, done } = await connection.reader.read().catch( error => {
            console.log (`read error: ${error}`)
            throw error
        })
        if (done) {
            connection.reader.releaseLock()
            break
        }
        
        if (value) {
            // value is a Uint8Array - transform to a string
            value.forEach(v => {
                
                if (v >= 32 && v <= 126 ) // only transform printable characters
                    data += String.fromCharCode(v)
                else if (v === 13)
                    cr = true
            })
        }
        if (cr) break
    }
    return data
}

export const close = async (connection) => {
    
    console.log('closing serial connection')

    setTimeout( async () => {
        if(!connection)
            throw new Error('Close requires a valid connection object')

        await connection.reader.cancel()
        await connection.writer.close()
        await connection.port.close()
        console.log('connection closed')
    }, constants.readTimeout) // wait for the last read request to finish before closing connection
}
 