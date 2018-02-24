import ShaderCanvas, {Renderer} from "shader-canvas";

function fixTextureURL(filePath: string): string {
  // ../textures/foo.jpg -> textures/foo.jpg
  return filePath.replace(/^\.\.\//, '');
}

function shaderIsAnimated(shaderSource: string): boolean {
  return /(u_time|iGlobalTime|u_mouse|iMouse)/.test(shaderSource);
}

export default class Shader {
  domElement: HTMLElement;
  private model: any;
  private isSolo: boolean;
  private isAnimated: boolean;
  private shaderCanvas: ShaderCanvas;

  constructor(model: any, isSolo: boolean = false, renderer?: Renderer) {
    this.model = model;
    this.isSolo = isSolo;

    if (!this.isSolo) {
      let el = document.createElement("a");
      el.href = `#${this.model.slug}`;
      el.addEventListener("click", (e) => {
        window.location.hash = `#${this.model.slug}`;
        window.location.reload();
      });
      this.domElement = el;
    } else {
      this.domElement = document.createElement("div");
    }

    this.domElement.classList.add("shader");
    this.domElement.classList.add("inactive");

    const metaTop = document.createElement("div");
    metaTop.classList.add("meta");
    this.domElement.appendChild(metaTop);

    const titleEl = document.createElement("span");
    titleEl.classList.add("title");
    titleEl.textContent = this.model.title;
    metaTop.appendChild(titleEl);

    const wrapper = document.createElement("div");
    wrapper.classList.add("canvas-wrapper");
    wrapper.id = `shader-${this.model.slug}`
    this.domElement.appendChild(wrapper);

    const metaBottom = document.createElement("div");
    metaBottom.classList.add("meta");
    this.domElement.appendChild(metaBottom);

    if (this.isSolo) {
      const sourceEl = document.createElement("pre");
      sourceEl.classList.add("shader-source");
      sourceEl.classList.add("hidden");
      sourceEl.textContent = this.model.raw_source;
      wrapper.appendChild(sourceEl);

      const sourceButton = document.createElement("a");
      sourceButton.classList.add("source");
      sourceButton.href = "javascript:";
      sourceButton.textContent = "source";
      metaTop.appendChild(sourceButton);

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
        window.location.reload();
      });
    }

    this.shaderCanvas = new ShaderCanvas({renderer});
    this.shaderCanvas.buildTextureURL = fixTextureURL;
    const includeDefaultUniforms = false;
    this.shaderCanvas.setShader(this.model.source, includeDefaultUniforms);
    wrapper.appendChild(this.shaderCanvas.domElement);

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

  render() {
    this.shaderCanvas.render();
  }

  setSize(width: number, height: number) {
    this.shaderCanvas.setSize(width, height);
  }

  naturalWidth(): number {
    // Fall back to sized by the document CSS temporarily:
    this.shaderCanvas.domElement.style.width = "";
    this.shaderCanvas.domElement.style.height = "";
    return this.shaderCanvas.domElement.clientWidth;
  }
}
