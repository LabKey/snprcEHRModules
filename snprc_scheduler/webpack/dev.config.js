require("babel-polyfill");
const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const devServer = {
    host: 'localhost',
    port: 3000,

    // enable the HMR on the server
    hot: true,

    headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
        "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
    },

    contentBase: './src/client/',
    compress: true,
    overlay: true
};

const devServerURL = 'http://' + devServer.host + ':' + devServer.port;

module.exports = {
    context: path.resolve(__dirname, '..'),

    mode: "development",

    devtool: 'eval-source-map',

    devServer: devServer,

    entry: {
        'app': [
            // activate HMR for React
            'react-hot-loader/patch',

            // bundle the client for webpack-dev-server
            // and connect to the provided endpoint
            'webpack-dev-server/client?' + devServerURL,

            'webpack/hot/only-dev-server',

            './src/client/app.js',

            './src/client/styles/style.js'
        ]
    },
    output: {
        path: path.resolve(__dirname, '../resources/web/snprc_scheduler/app/'),
        publicPath: devServerURL + '/',
        filename: '[name].js'
    },
    externals: {
        'react/addons': true,
        'react/lib/ExecutionEnvironment': true,
        'react/lib/ReactContext': true
    },
    module: {
        rules: [
            {
                test: /\.jsx?$/,
                // loaders: ['babel-loader',]
                loaders: [{
                    loader: 'babel-loader',
                    options: {
                        cacheDirectory: true,
                        plugins: [
                            "react-hot-loader/babel"
                        ]
                    }
                }]
            },
            {
                test: /\.css$/,
                use: [
                    'css-hot-loader',
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                ]
            },
            {
                test: /style.js/,
                loaders: [{
                    loader: 'babel-loader',
                    options: {
                        cacheDirectory: true
                    }
                }]
            }
        ]
    },
    plugins: [
        // enable HMR globally
        new webpack.HotModuleReplacementPlugin(),

        // prints more readable modules names in the browser console on HMR updates
        new webpack.NamedModulesPlugin(),

        // do not emit compiled assets that include errors
        new webpack.NoEmitOnErrorsPlugin(),

        new MiniCssExtractPlugin({
            filename: '[name].css'
        })
    ],
    resolve: { extensions: [ '.jsx', '.js' ] }
};