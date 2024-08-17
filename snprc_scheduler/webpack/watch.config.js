const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const path = require('path');

const devServer = {
    client: {
        overlay: true,
    },
    host: 'localhost',
    port: 3000,
    hot: 'only',
    headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
        "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
    },
};

const devServerURL = 'http://' + devServer.host + ':' + devServer.port;

module.exports = {
    context: path.resolve(__dirname, '..'),

    mode: 'development',

    devServer: devServer,

    entry: {
        app: [
            'react-hot-loader/patch',
            './src/client/app.js',
            './src/client/styles/style.js',
        ]
    },

    output: {
        path: path.resolve(__dirname, '../resources/web/snprc_scheduler/gen/app/'),
        publicPath: devServerURL + '/',
        filename: "[name].js"
    },
    module: {
        rules: [{
            test: /\.jsx?$/,
            use: [{
                loader: 'babel-loader',
                options: {
                    cacheDirectory: true,
                }
            }]
        },{
            test: /\.css$/,
            use: [MiniCssExtractPlugin.loader, 'css-loader']
        }]
    },
    optimization: {
        // do not emit compiled assets that include errors
        emitOnErrors: false,
    },
    resolve: {
        extensions: [ '.jsx', '.js' ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: '[name].css'
        })
    ]
};
