import "./style.scss";
import models from "./models";
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

  // Now that we've activated the ones within the viewport, there might still be
  // a few open slots, which we can use for the ones nearest to the viewport.

  // Next, if there are still inactive shaders, we can start recording frames
  // for the active ones.

  // When we've finished a recording, we can deactivate the shader and swap the
  // frames in for the canvas. We can then cycle these frames in place, to get
  // an animated preview.

  // After deactivating a shader, we can look for the next inactive nearby
  // shader and repeat this process. Eventually, every shader on the page will
  // be either active or showing preview images.
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
