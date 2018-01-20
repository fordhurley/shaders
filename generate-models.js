const fs = require("fs");
const path = require("path");
const glslify = require("glslify");
const slugify = require("slugify");
const yaml = require("js-yaml");

// This is a custom webpack loader, which takes in a raw JSON string (listing of
// shaders) and outputs a javascript module. The resulting module exports an
// array of model objects.

function readFile(filePath) {
  return new Promise(function(resolve, reject) {
    fs.readFile(filePath, "utf-8", function(err, contents) {
      if (err) {
        reject(err);
      } else {
        resolve(contents);
      }
    });
  });
}

module.exports = function(source) {
  var callback = this.async();

  const modelNames = yaml.load(source);

  Promise.all(modelNames.map(([name, title]) => {
    const shaderPath = path.resolve(`shaders/${name}.glsl`);
    this.addDependency(shaderPath);
    return readFile(shaderPath).then(function(raw_source) {
      const source = glslify.compile(raw_source, {
        basedir: path.dirname(shaderPath)
      });
      return {
        title: title,
        slug: slugify(title),
        raw_source: raw_source,
        source: source,
      };
    });
  })).then(function(models) {
    const output = "export default " + JSON.stringify(models);
    callback(null, output);
  }).catch(callback);
};
