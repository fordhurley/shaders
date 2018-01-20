import {WebGLRenderer} from "three";
import ScrollMonitor from "scrollmonitor";

import "./style.scss";
import models from "./models.json";
import Shader from "./shader";

function shaderWidth(shader) {
  shader.canvas.style = {}; // fall back to document style temporarily
  return shader.canvas.clientWidth;
}

function initSingleShader(slug) {
  const model = models.find(m => m.slug === slug);
  if (!model) {
    throw new Error("No model found for: " + slug);
  }

  const main = document.querySelector("main");
  main.classList.add("solo");
  const shader = new Shader(model, {solo: true});
  shader.activate();
  main.appendChild(shader.domElement);

  function resize() {
    const width = shaderWidth(shader);
    shader.setSize(width, width);
    ScrollMonitor.recalculateLocations();
  }
  window.addEventListener("resize", resize);
  resize();
}

function initAllShaders() {
  const shaders = models.map((m) => {
    return new Shader(m);
  });

  const main = document.querySelector("main");
  shaders.forEach((s) => {
    main.appendChild(s.domElement);
  });

  const renderer = new WebGLRenderer();
  renderer.setPixelRatio(window.devicePixelRatio);

  function resize() {
    const width = shaderWidth(shaders[0])
    shaders.forEach((shader) => {
      shader.setSize(width, width);
    });
    renderer.setSize(width, width);
    ScrollMonitor.recalculateLocations();
  }
  window.addEventListener("resize", resize);
  resize();

  shaders.forEach((shader) => {
    shader.activate(renderer);
  });
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
