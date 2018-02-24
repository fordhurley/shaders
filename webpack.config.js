const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");

module.exports = {
  entry: "./gallery/index.ts",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "build"),
  },
  devServer: {
    contentBase: "./build",
    host: "fords-macbook-pro.local",
  },
  devtool: "source-map",
  resolve: {
    extensions: [".ts", ".js"],
  },
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({use: ["css-loader", "sass-loader"]}),
      },
      {
        test: /\.(png|svg|jpg|gif)$/,
        use: ["file-loader"],
      },
      {
        test: /models\.yaml$/,
        use: [path.resolve("generate-models.js")],
      },
      {
        test: /\.(t|j)s$/,
        use: {loader: "awesome-typescript-loader"},
      },
      {
        enforce: "pre",
        test: /\.js$/,
        loader: "source-map-loader"
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./gallery/index.html",
    }),
    new ExtractTextPlugin("style.css"),
    new CopyWebpackPlugin([
      {from: "textures", to: "textures"},
    ]),
  ],
};

if (!process.env.DEBUG) {
  module.exports.plugins.push(new UglifyJsPlugin({
    sourceMap: true
  }));
}
