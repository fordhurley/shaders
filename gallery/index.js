import "./style.scss";
import models from "./models";
import Shader from "./shader";

const shaders = [];

function init() {
  const main = document.querySelector("main");

  if (window.location.hash) {
    const slug = window.location.hash.slice(1);
    model = models.find(m => m.slug === shaderSlug);
    if (!model) {
      throw new Error("No model found for: " + shaderSlug);
    }
    main.classList.add("solo");
    const shader = new Shader(model, {solo: true});
    shaders.push(shader);
    main.appendChild(shader.domElement);
    return;
  }

  models.forEach(function(model) {
    const shader = new Shader(model);
    shaders.push(shader);
    main.appendChild(shader.domElement);
  });
}
init();
