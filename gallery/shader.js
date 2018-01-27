import ShaderCanvas from "shader-canvas";

function fixTextureURL(filePath) {
  // ../textures/foo.jpg -> textures/foo.jpg
  return filePath.replace(/^\.\.\//, '');
}

function shaderIsAnimated(shaderSource) {
  return /(u_time|iGlobalTime|u_mouse|iMouse)/.test(shaderSource);

}

export default class Shader {
  constructor(model, {solo, renderer} = {}) {
    this.model = model;
    this.solo = solo;

    this.domElement = document.createElement(this.solo ? "div" : "a");
    this.domElement.classList.add("shader");
    this.domElement.classList.add("inactive");

    if (!this.solo) {
      this.domElement.href = `#${this.model.slug}`;
      this.domElement.addEventListener("click", function(e) {
        window.location.hash = `#${this.model.slug}`;
        window.location.reload();
      }.bind(this));
    }

    const metaTop = document.createElement("div");
    metaTop.classList.add("meta");
    this.domElement.appendChild(metaTop);

    let titleEl = document.createElement("span");
    titleEl.classList.add("title");
    titleEl.textContent = this.model.title;
    metaTop.appendChild(titleEl);

    this.wrapper = document.createElement("div");
    this.wrapper.classList.add("canvas-wrapper");
    this.wrapper.id = `shader-${this.model.slug}`
    this.domElement.appendChild(this.wrapper);

    const metaBottom = document.createElement("div");
    metaBottom.classList.add("meta");
    this.domElement.appendChild(metaBottom);

    if (this.solo) {
      const sourceEl = document.createElement("pre");
      sourceEl.classList.add("shader-source");
      sourceEl.classList.add("hidden");
      sourceEl.textContent = this.model.raw_source;
      this.wrapper.appendChild(sourceEl);

      const sourceButton = document.createElement("a");
      sourceButton.classList.add("source");
      sourceButton.href = "javascript:";
      sourceButton.textContent = "source";
      metaTop.append(sourceButton);

      sourceButton.addEventListener("click", function(e) {
        e.preventDefault();
        sourceEl.classList.toggle("hidden");
      });

      const moreButton = document.createElement("a");
      moreButton.href = "./";
      moreButton.textContent = "more";
      metaBottom.appendChild(moreButton);

      // Trigger a reload when pressing the back button from here:
      window.addEventListener("hashchange", function(e) {
        window.location = window.location;
      });
    }

    this.shaderCanvas = new ShaderCanvas({renderer});
    this.shaderCanvas.buildTextureURL = fixTextureURL;
    const includeDefaultUniforms = false;
    this.shaderCanvas.setShader(this.model.source, includeDefaultUniforms);
    this.wrapper.appendChild(this.shaderCanvas.domElement);

    this.isAnimated = shaderIsAnimated(this.model.source);
  }

  run() {
    if (this.isAnimated && this.shaderCanvas.paused) {
      this.shaderCanvas.togglePause();
    }
  }

  pause() {
    if (!this.shaderCanvas.paused) {
      this.shaderCanvas.togglePause();
    }
  }

  setSize(width, height) {
    this.shaderCanvas.setSize(width, height);
  }

  naturalWidth() {
    this.shaderCanvas.domElement.style = {}; // fall back to document style temporarily
    return this.shaderCanvas.domElement.clientWidth;
  }
}
