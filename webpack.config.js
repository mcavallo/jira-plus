const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const AnyBarWebpackPlugin = require('anybar-webpack')


module.exports = () => {

  const isProd =
    (process.argv.indexOf('-p') !== -1)

  const devtool =
    isProd ? "none" : "source-map" // or "inline-source-map"

  const commonPlugins = [
    new CleanWebpackPlugin(['dist'], {
      verbose: false
    }),

    new HtmlWebpackPlugin({
      template: __dirname + '/src/options/options.html',
      filename: 'options.html',
      inject: 'body',
      hash: true
    }),

    new ExtractTextPlugin(
      '[name].css'
    ),

    new CopyWebpackPlugin([{
      context: __dirname + '/src/extension-files/',
      from: '**/*.{json,png}',
      to: __dirname + '/dist'
    }], {
      copyUnmodified: true
    })
  ]

  const devOnlyplugins = [
    new AnyBarWebpackPlugin()
  ]

  const plugins =
    commonPlugins.concat(isProd ? [] : devOnlyplugins)

  return {
    entry: {
      'options': './src/options/options.js',
      'content': './src/content/content.js'
    },
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
              debug: !isProd,
              forceWatch: !isProd
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
    devtool,
    plugins
  }
}
