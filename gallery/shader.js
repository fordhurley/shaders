import ScrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";

function fixTextureURL(filePath) {
  // ../textures/foo.jpg -> textures/foo.jpg
  return filePath.replace(/^\.\.\//, '');
};

export default class Shader {
  constructor(model, {solo} = {}) {
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

      const backButton = document.createElement("a");
      backButton.href = "./";
      backButton.textContent = "more";
      metaBottom.appendChild(backButton);
    }

    this.canvas = document.createElement("canvas");
    this.wrapper.appendChild(this.canvas);

    this.monitor = ScrollMonitor.create(this.domElement);
    this.monitor.enterViewport(this.togglePauseIfNeeded.bind(this));
    this.monitor.fullyEnterViewport(this.togglePauseIfNeeded.bind(this));
    this.monitor.partiallyExitViewport(this.togglePauseIfNeeded.bind(this));
    this.monitor.exitViewport(this.togglePauseIfNeeded.bind(this));

    this.resize = this.resize.bind(this);
    window.addEventListener("resize", this.resize);
    this.resize();

    this.isActive = false;
  }

  activate() {
    this.isActive = true;
    this.domElement.classList.remove("inactive");

    this.shaderCanvas = new ShaderCanvas({domElement: this.canvas});
    this.shaderCanvas.buildTextureURL = fixTextureURL
    this.shaderCanvas.setShader(this.model.source);
    this.shaderCanvas.togglePause();

    this.resize();
    this.togglePauseIfNeeded();
  }

  deactivate() {
    this.isActive = false;
    this.domElement.classList.add("inactive");

    if (this.shaderCanvas) {
      console.log("calling dispose");
      this.shaderCanvas.dispose();
      this.wrapper.removeChild(this.canvas);
      this.canvas = document.createElement("canvas");
      this.wrapper.appendChild(this.canvas);
      this.shaderCanvas = null;
    }
  }

  togglePauseIfNeeded() {
    if (!this.shaderCanvas) {
      return;
    }

    let shouldBePlaying = this.monitor.isInViewport;
    if (!this.solo) {
      // Oddly, I've discovered that it's possible for isFullyInViewport to be
      // true, but isInViewport to be false. Checking both is more reliable.
      shouldBePlaying = this.monitor.isInViewport && this.monitor.isFullyInViewport;
    }
    // Easier to check the logic if it's named sensibly:
    const shouldBePaused = !shouldBePlaying;
    if (this.shaderCanvas.paused !== shouldBePaused) {
      this.shaderCanvas.togglePause();
    }
  }

  resize() {
    this.canvas.style = {}; // fall back to document style temporarily
    const width = this.canvas.clientWidth;
    if (this.shaderCanvas) {
      this.shaderCanvas.setSize(width, width);
    } else {
      this.canvas.width = this.canvas.height = width * window.devicePixelRatio;
      this.canvas.style.width = this.canvas.style.height = width + "px";
    }
    ScrollMonitor.recalculateLocations();
  }
}
