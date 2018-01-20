import {WebGLRenderer} from "three";
import ScrollMonitor from "scrollmonitor";

import "./style.scss";
import models from "./models.json";
import Shader from "./shader";

function shaderWidth(shader) {
  shader.canvas.style = {}; // fall back to document style temporarily
  return shader.canvas.clientWidth;
}

function getContainer() {
  return document.querySelector("main");
}

function makeMonitor(shader) {
  const monitor = ScrollMonitor.create(shader.domElement);

  function togglePauseIfNeeded() {
    // Oddly, I've discovered that it's possible for isFullyInViewport to be
    // true, but isInViewport to be false. Checking both is more reliable.
    const shouldBePlaying = monitor.isInViewport && monitor.isFullyInViewport;
    // Easier to check the logic if it's named sensibly:
    const shouldBePaused = !shouldBePlaying;
    if (shader.shaderCanvas.paused !== shouldBePaused) {
      shader.shaderCanvas.togglePause();
    }
  }
  togglePauseIfNeeded();

  monitor.enterViewport(togglePauseIfNeeded);
  monitor.fullyEnterViewport(togglePauseIfNeeded);
  monitor.partiallyExitViewport(togglePauseIfNeeded);
  monitor.exitViewport(togglePauseIfNeeded);
  return monitor;
}

function initSingleShader(slug) {
  const model = models.find(m => m.slug === slug);
  if (!model) {
    throw new Error("No model found for: " + slug);
  }

  const container = getContainer();
  container.classList.add("solo");
  const shader = new Shader(model, {solo: true});
  shader.activate();
  container.appendChild(shader.domElement);

  function resize() {
    const width = shaderWidth(shader);
    shader.setSize(width, width);
  }
  window.addEventListener("resize", resize);
  setTimeout(resize, 0);
}

function initAllShaders() {
  const shaders = models.map((m) => {
    return new Shader(m);
  });

  const container = getContainer();
  shaders.forEach((s) => {
    container.appendChild(s.domElement);
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

  shaders.forEach((shader) => {
    shader.activate(renderer);
    makeMonitor(shader);
  });

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
