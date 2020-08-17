import constants from '../../constants/index'

export const requestPort =  () => {
    return ( {port: {readable: {}, writable: {}} })
}

export const connect = async (port, serialOptions) => {
    if (!port || !serialOptions)
        throw new Error('Connection request requires port and serialOptions')

    
    await port.open( serialOptions ).catch( error => {
        throw new Error(`Port.open() error: ${error.message}`)
    })

    const decoder = new TextDecoderStream();
    const inputDone = port.readable.pipeTo(decoder.writable)
    const inputStream = decoder.readable

    const encoder = new TextEncoderStream()
    const outputDone = encoder.readable.pipeTo(port.writable)
    const outputStream = encoder.writable
    
    const connection = {
        port: port,
        serialOptions: serialOptions,
        reader: inputStream.getReader(),
        writer: outputStream.getWriter(),

        inputDone: inputDone,
        outputDone: outputDone,
        inputStream: inputStream,
        outputStream: outputStream
    }

    return connection
}


export const readWithTimeout = function (ms, promise) {

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
        promise.then(value => {
            clearTimeout(timerId)
            return value
        }),
        timeout
    ])
}

export const read = async (connection) => {
    if (!connection)
        throw new Error('Read requires a valid connection object')

    return '1C45433F, 23.4'

}

export const close = async (connection) => {
    if(!connection)
        throw new Error('Close requires a valid connection object')

    if (connection.reader) {
        await connection.reader.cancel()
        await connection.inputDone.catch(() => {})
    }

    if (connection.outputStream) {
        await connection.writer.close()
        connection.outputDone = null
    }

    connection.port = null
}
 