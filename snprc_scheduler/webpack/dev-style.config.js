
const path = require("path");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    context: path.resolve(__dirname, '..'),

    entry: {
        'app': [
            './src/client/styles/style.js'
        ]
    },

    output: {
        path: path.resolve(__dirname, '../resources/web/snprc_scheduler/app/'),
        publicPath: '/labkey/snprc_scheduler/',
        filename: 'style.js' // do not override app.js
    },

    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    {
                        loader: MiniCssExtractPlugin.loader
                    },
                    'css-loader'
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
        new MiniCssExtractPlugin({
            filename: '[name].css'
        })
    ]
};