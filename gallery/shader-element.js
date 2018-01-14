import ScrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";

function fixTextureURL(filePath) {
  // ../textures/foo.jpg -> textures/foo.jpg
  return filePath.replace(/^\.\.\//, '');
};

export default function makeShaderElement(shader, solo) {
  const tagName = solo ? "div" : "a";
  const el = document.createElement(tagName);
  el.classList.add("shader");

  if (!solo) {
    el.href = `#${shader.slug}`;
    el.addEventListener("click", function(e) {
      window.location.hash = `#${shader.slug}`;
      window.location.reload();
    });
  }

  const metaTop = document.createElement("div");
  metaTop.classList.add("meta");
  el.appendChild(metaTop);

  let titleEl = document.createElement("span");
  titleEl.classList.add("title");
  titleEl.textContent = shader.title;
  metaTop.appendChild(titleEl);

  const wrapper = document.createElement("div");
  wrapper.classList.add("canvas-wrapper");
  wrapper.id = `shader-${shader.slug}`
  el.appendChild(wrapper);

  const metaBottom = document.createElement("div");
  metaBottom.classList.add("meta");
  el.appendChild(metaBottom);

  if (solo) {
    const sourceEl = document.createElement("pre");
    sourceEl.classList.add("shader-source");
    sourceEl.classList.add("hidden");
    sourceEl.textContent = shader.raw_source;
    wrapper.appendChild(sourceEl);

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

  const shaderCanvas = new ShaderCanvas();
  shaderCanvas.buildTextureURL = fixTextureURL
  setTimeout(shaderCanvas.setShader.bind(shaderCanvas, shader.source), 0);
  wrapper.appendChild(shaderCanvas.domElement);
  shaderCanvas.togglePause();

  const monitor = ScrollMonitor.create(shaderCanvas.domElement);

  function togglePauseIfNeeded() {
    let shouldBePlaying = monitor.isInViewport;
    if (!solo) {
      // Oddly, I've discovered that it's possible for isFullyInViewport to be
      // true, but isInViewport to be false. Checking both is more reliable.
      shouldBePlaying = monitor.isInViewport && monitor.isFullyInViewport;
    }
    // Easier to check the logic if it's named sensibly:
    const shouldBePaused = !shouldBePlaying;
    if (shaderCanvas.paused !== shouldBePaused) {
      shaderCanvas.togglePause();
    }
  }

  function resize() {
    shaderCanvas.domElement.style = {}; // fall back to document style temporarily
    const width = shaderCanvas.domElement.clientWidth;
    shaderCanvas.setSize(width, width);
    ScrollMonitor.recalculateLocations();
  }
  window.addEventListener("resize", resize);

  function initShader() {
    monitor.enterViewport(togglePauseIfNeeded);
    monitor.fullyEnterViewport(togglePauseIfNeeded);
    monitor.partiallyExitViewport(togglePauseIfNeeded);
    monitor.exitViewport(togglePauseIfNeeded);
    resize();
  }

  if (document.readyState === "complete") {
    setTimeout(initShader, 0);
  } else {
    window.addEventListener("load", initShader);
  }

  el.dispose = function() {
    window.removeEventListener("resize", resize);
    shaderCanvas.dispose();
    monitor.destroy();
  };

  return el;
}
