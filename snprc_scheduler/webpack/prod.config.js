const path = require('path');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    context: path.resolve(__dirname, '..'),

    mode: 'production',

    devtool: 'source-map',

    entry: {
        app: [
            './src/client/app.js',
            './src/client/styles/style.js'
        ]
    },

    output: {
        path: path.resolve(__dirname, '../resources/web/snprc_scheduler/gen/app/'),
        publicPath: './', // allows context path to resolve in both js/css
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
        },
        {
            test: /\.css$/,
            use: [MiniCssExtractPlugin.loader, 'css-loader']
        }]
    },
    resolve: {
        extensions: [ '.jsx', '.js' ]
    },
    plugins: [
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': '"production"'
        }),
        new MiniCssExtractPlugin({
            filename: '[name].css'
        })
    ]
};
