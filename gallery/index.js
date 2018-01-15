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
    if (numActive >= MAX_ACTIVE || !shader.monitor.isInViewport) {
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

function initSingleShader(slug) {
  const model = models.find(m => m.slug === slug);
  if (!model) {
    throw new Error("No model found for: " + slug);
  }

  const main = document.querySelector("main");
  main.classList.add("solo");
  const shader = new Shader(model, {solo: true});
  shader.resize();
  shader.activate();
  main.appendChild(shader.domElement);
}

function initAllShaders() {
  const shaders = models.map((m) => {
    return new Shader(m);
  });

  const main = document.querySelector("main");
  shaders.forEach((s) => {
    main.appendChild(s.domElement);
  });

  watch(shaders);
}

function init() {
  if (window.location.hash) {
    const slug = window.location.hash.slice(1);
    initSingleShader(slug);
    return;
  }

  initAllShaders();
}

if (document.readyState === "complete") {
  setTimeout(init, 0);
} else {
  window.addEventListener("load", init);
}
