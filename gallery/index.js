import scrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";

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

function makeShaderEl(shader) {
  const MAX_SIZE = 600;

  const el = document.createElement("div");
  el.classList.add("shader");

  const metaTop = document.createElement("div");
  metaTop.classList.add("meta");
  metaTop.classList.add("top");
  metaTop.innerHTML = `
    <span>${shader.title}</span>
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
  sourceEl.textContent = shader.source;
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
  shaderCanvas.setShader(shader.source);
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

let shader;
if (window.location.hash) {
  const slug = window.location.hash.slice(1);
  shader = shaders.find(s => s.slug === slug);
  if (!shader) {
    console.warn("No shader found for:", window.location.hash);
  }
}

if (shader) {
  main.appendChild(makeShaderEl(shader));
} else {
  shaders.forEach(function(shader) {
    main.appendChild(makeShaderEl(shader));
  });
}
