const fs = require("fs");
const path = require("path");
const glslify = require("glslify");
const slugify = require("slugify");

// This is a custom webpack loader, which takes in a raw JSON string (listing of
// shaders) and outputs a javascript module. The resulting module exports an
// array of model objects.

module.exports = function(source) {
  var callback = this.async();

  let models = [];

  function oneLoaded(model) {
    let allLoaded = true;
    models.forEach((model) => {
      allLoaded = allLoaded && model.source !== undefined;
    });
    if (!allLoaded) {
      return;
    }
    const output = "export default " + JSON.stringify(models);
    callback(null, output);
  }

  const modelNames = JSON.parse(source);

  modelNames.forEach(([name, title]) => {
    var model = {
      title: title,
      slug: slugify(title),
    };
    models.push(model);

    const shaderPath = path.resolve(`shaders/${name}.glsl`);

    this.addDependency(shaderPath);

    fs.readFile(shaderPath, "utf-8", function(err, raw_source) {
      if (err) {
        callback(err);
        return;
      }
      model.raw_source = raw_source;
      model.source = glslify.compile(raw_source, {basedir: path.dirname(shaderPath)});
      oneLoaded();
    });
  });
}
