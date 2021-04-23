/* eslint-disable func-names */
export const requestPort = async () => {
    return ({ port: { readable: {}, writable: {} } })
}

export const connect = async (port, serialOptions) => {
    const inputDone = null
    const inputStream = null

    const outputDone = null
    const outputStream = null

    const connection = {
        port,
        serialOptions,
        reader: null,
        writer: null,

        inputDone,
        outputDone,
        inputStream,
        outputStream
    }
    return connection
}

export const readWithTimeout = function (ms, promise) {
    promise.then(value => {
        return value
    })
    // let timerId = null;

    // // Create a promise that rejects in the specified timeout period (ms)
    // let timeout = new Promise((resolve, reject) => {
    //     timerId = setTimeout(() => {
    //         clearTimeout(timerId)
    //         reject(new Error (constants.timeOutErrorMessage))
    //     }, ms)
    // })

    // // Returns a race between our timeout and the passed in promise
    // return Promise.race([
    //     promise.then(value => {
    //         clearTimeout(timerId)
    //         return value
    //     }),
    //     timeout
    // ])
}

export const read = async connection => {
    if (!connection) throw new Error('Read requires a valid connection object')

    return '1C45433F, 23.4'
}

export const close = async connection => {
    if (!connection) throw new Error('Close requires a valid connection object')
}
