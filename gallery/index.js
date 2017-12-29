import scrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";
import slugify from "slugify";

import "./style.scss";
import shaders from "./shaders";

function pauseWhenScrolledOffscreen(shaderCanvas) {
  var monitor = scrollMonitor.create(shaderCanvas.domElement);
  if (shaderCanvas.paused !== monitor.isInViewport) {
    shaderCanvas.togglePause();
  }
  monitor.enterViewport(function() {
    if (shaderCanvas.paused) {
      shaderCanvas.togglePause();
    }
  });
  monitor.exitViewport(function() {
    if (!shaderCanvas.paused) {
      shaderCanvas.togglePause();
    }
  });
}

function makeShader(source, title) {
  const MAX_SIZE = 600;

  const slug = slugify(title);

  const el = document.createElement("div");
  el.classList.add("shader");

  const metaTop = document.createElement("div");
  metaTop.classList.add("meta");
  metaTop.classList.add("top");
  metaTop.innerHTML = `
    <span>${title}</span>
    <a class="source hidden" href="javascript:">source</a>
  `;
  el.appendChild(metaTop);

  const wrapper = document.createElement("div");
  wrapper.classList.add("canvas-wrapper");
  wrapper.id = "shader-${slug}"
  el.appendChild(wrapper);

  const sourceEl = document.createElement("pre");
  sourceEl.classList.add("shader-source");
  sourceEl.classList.add("hidden");
  sourceEl.textContent = source;
  wrapper.appendChild(sourceEl);

  const sourceButton = metaTop.querySelector(".source");
  sourceButton.addEventListener("click", function(e) {
    e.preventDefault();
    sourceEl.classList.toggle("hidden");
  });

  const shaderCanvas = new ShaderCanvas();
  shaderCanvas.buildTextureURL = function(filePath) {
    // ../textures/foo.jpg -> textures/foo.jpg
    return filePath.replace(/^\.\.\//, '');
  };
  shaderCanvas.setShader(source);
  wrapper.appendChild(shaderCanvas.domElement);
  shaderCanvas.togglePause();

  function resize() {
    shaderCanvas.domElement.style = {}; // fall back to document style temporarily
    var style = window.getComputedStyle(shaderCanvas.domElement);
    var width = parseFloat(style.width);
    var size = Math.min(width, MAX_SIZE);
    shaderCanvas.setSize(size, size);
  }
  window.addEventListener("resize", resize);

  window.addEventListener("load", function() {
    resize();
    pauseWhenScrolledOffscreen(shaderCanvas);
  });

  return el;
}

const main = document.querySelector("main");
shaders.forEach(function(shader) {
  main.appendChild(makeShader(shader.source, shader.title));
})
