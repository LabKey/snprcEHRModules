export default {
    debug: false,
    notSupportedMessage: `Sorry, Serial.API is not supported on this device, make sure you're
    running Chrome 78 or later and have enabled the #enable-experimental-web-platform-features flag in
    chrome://flags`,
    timeOutErrorMessage: 'Chip reader is not responding. Ensure you are connected to the correct port, and the reader is turned on.',
    validSerialOptions: ['baudRate', 'dataBits', 'stopBits', 'parity', 'bufferSize', 'flowControl'],
    readTimeout: 3000, // 3300 milliseconds
    defaultSerialOptions: {
        baudRate: 19200,
        dataBits: 8,
        stopBits: 1,
        bufferSize: 255,
        parity: 'none',
        flowControl: 'none'
    }
}

// https://wicg.github.io/serial/#dom-serial or https://reillyeon.github.io/serial/#dom-serialoptions
// parity is an enum:   "none",  "even",  "odd",  "mark",  "space"
// baudrate member: One of 115200, 57600, 38400, 19200, 9600, 4800, 2400, 1800, 1200, 600, 300, 200, 150, 134, 110, 75, or 50.
// databits member: One of 8, 7, 6, or 5.
// stopbits member: One of 1 or 2.
// rctscts, xon, xoff, xany: boolean - stopped working in Chrome ver. 86 - switched to 'flowControl'
// property names switched to camelCase in Chrome ver. 86  Arrrrg
