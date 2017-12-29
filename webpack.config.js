const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = {
  entry: "./gallery/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "build"),
  },
  devServer: {
    contentBase: "./build",
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
        test: /\.glsl$/,
        use: ["raw-loader", "glslify-loader"],
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
