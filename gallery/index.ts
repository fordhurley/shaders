import {WebGLRenderer} from "three";
import ScrollMonitor from "scrollmonitor";

import "./style.scss";
// import models from "./models.yaml";
import Shader from "./shader";

function getContainer() {
  return document.querySelector("main")!;
}

function makeMonitor(shader) {
  const monitor = ScrollMonitor.create(shader.domElement);

  function runWhenVisible() {
    if (monitor.isInViewport) {
      shader.run();
    } else {
      shader.pause();
    }
  }
  runWhenVisible();

  monitor.enterViewport(runWhenVisible);
  monitor.fullyEnterViewport(runWhenVisible);
  monitor.partiallyExitViewport(runWhenVisible);
  monitor.exitViewport(runWhenVisible);

  return monitor;
}

const models = [
  "foo",
];

function initSingleShader(slug) {
  const model = models.find(m => m.slug === slug);
  if (!model) {
    throw new Error("No model found for: " + slug);
  }

  const container = getContainer();
  container.classList.add("solo");
  const shader = new Shader(model, true);
  container.appendChild(shader.domElement);

  function resize() {
    const width = shader.naturalWidth();
    shader.setSize(width, width);
  }
  window.addEventListener("resize", resize);
  setTimeout(resize, 0);
}

function initAllShaders() {
  // Make a single renderer to share between all of them:
  const renderer = new WebGLRenderer();
  renderer.setPixelRatio(window.devicePixelRatio);

  const shaders = models.map((m) => {
    return new Shader(m, false, renderer);
  });

  const container = getContainer();
  shaders.forEach((shader) => {
    container.appendChild(shader.domElement);
    makeMonitor(shader);
  });

  let lastWidth = null;
  function resize() {
    const width = shaders[0].naturalWidth();
    if (width === lastWidth) {
      return;
    }
    lastWidth = width;
    renderer.setSize(width, width);
    shaders.forEach((shader) => {
      shader.setSize(width, width);
      shader.shaderCanvas.render(); // because changing the size clears the canvas
    });
    ScrollMonitor.recalculateLocations();
  }
  window.addEventListener("resize", resize);

  setTimeout(resize, 100);
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
