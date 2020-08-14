import constants from '../constants/index'

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

export const write = async (connection, text) => {
    if (!connection)
        throw new Error('Write requires a valid connection object')

    await connection.writer.write(text)
    await connection.writer.write('\r')

}

export const read = async (connection) => {

    if (!connection)
        throw new Error('Read requires a valid connection object')

    let response = ''
    while (true)  {
        const { value } = await connection.reader.read().catch( error => {
            throw error
        })
        if (value) {
            response += value
        }

        if (value) {
            if (value.indexOf('\r') > -1) {
                break
            }
        }
        else
            break
     }
    return response

     
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

    
    await connection.port.close()
    connection.port = null
}
 