const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const UglifyJSPlugin = require('uglifyjs-webpack-plugin')
const AnyBarWebpackPlugin = require('anybar-webpack')
const isProduction = (process.argv.indexOf('-p') !== -1)

module.exports = {
  entry: {
    'options': './src/options/options.js',
    'content': './src/content/content.js'
  },
  devtool: "source-map", // or "inline-source-map"
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env']
          }
        }
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [{
          loader: 'elm-webpack-loader',
          options: {
            debug: !isProduction,
            forceWatch: !isProduction
          }
        }]
      },
      {
        test: /\.(css|scss|sass)$/,
        loader: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader', 'sass-loader']
        })
      }
    ]
  },
  output: {
    path: __dirname + '/dist',
    filename: "[name].js"
  },
  plugins: [
    new CleanWebpackPlugin(['dist'], {
      verbose: false
    }),
    new HtmlWebpackPlugin ({
      template: __dirname + '/src/options/options.html',
      filename: 'options.html',
      inject: 'body',
      hash: true
    }),
    new ExtractTextPlugin(
      '[name].css'
    ),
    new CopyWebpackPlugin([
      {
        context: __dirname + '/src/extension-files/',
        from: '**/*.{json,png}',
        to: __dirname + '/dist'
      }
    ], {
      copyUnmodified: true
    }),
    new AnyBarWebpackPlugin(),
    /*
    new UglifyJSPlugin({
      sourceMap: true,
      uglifyOptions: {
        ie8: false,
        ecma: 8
      }
    })
    */
  ]
}
