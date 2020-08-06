
    export const bluetoothRequest = (logger) => {
        let options = {};
        options.acceptAllDevices = true;

        logger('Requesting Bluetooth Device...');
        logger('with ' + JSON.stringify(options));
        navigator.bluetooth.requestDevice(options)
            .then(device => {
                logger(`> Name:      ${device.name}`);
                logger(`> Id:        ${device.id}`);
                logger(`> Connected: ${device.gatt.connected }`);
            })
            .catch(error => {
                logger(`error ${error}`);
            });
    }
