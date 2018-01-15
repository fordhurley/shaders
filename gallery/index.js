import "./style.scss";
import models from "./models.json";
import Shader from "./shader";

function watch(shaders) {
  const MAX_ACTIVE = 6;

  shaders.forEach((shader) => {
    shader.resize();
  });

  // Activate the first few:
  let numActive = 0;
  shaders.forEach((shader) => {
    if (numActive >= MAX_ACTIVE) {
      return;
    }
    if (!shader.monitor.isInViewport) {
      return;
    }
    shader.activate();
    numActive++;
  });

  function update() {
    const shader = shaders.find((shader) => {
      return !shader.isActive && !shader.hasThumbnail;
    });
    if (!shader) {
      return;
    }
    requestAnimationFrame(update);

    shader.activate();
    shader.shaderCanvas.render();
    const src = shader.canvas.toDataURL();
    shader.deactivate();
    shader.resize();

    shader.hasThumbnail = true;

    var img = new Image();
    img.classList.add("thumbnail");
    img.src = src;
    shader.wrapper.appendChild(img);
  }
  requestAnimationFrame(update);
}

function init() {
  const shaders = [];

  const main = document.querySelector("main");

  if (window.location.hash) {
    const slug = window.location.hash.slice(1);
    const model = models.find(m => m.slug === slug);
    if (!model) {
      throw new Error("No model found for: " + slug);
    }
    main.classList.add("solo");
    const shader = new Shader(model, {solo: true});
    shaders.push(shader);
    main.appendChild(shader.domElement);
  } else {
    models.forEach(function(model) {
      const shader = new Shader(model);
      shaders.push(shader);
      main.appendChild(shader.domElement);
    });
  }

  watch(shaders);
}

if (document.readyState === "complete") {
  setTimeout(init, 0);
} else {
  window.addEventListener("load", init);
}
