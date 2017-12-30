import ScrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";

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
  wrapper.id = "shader-${slug}"
  el.appendChild(wrapper);

  const metaBottom = document.createElement("div");
  metaBottom.classList.add("meta");
  el.appendChild(metaBottom);

  if (solo) {
    const sourceEl = document.createElement("pre");
    sourceEl.classList.add("shader-source");
    sourceEl.classList.add("hidden");
    sourceEl.textContent = shader.source;
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
  shaderCanvas.buildTextureURL = function(filePath) {
    // ../textures/foo.jpg -> textures/foo.jpg
    return filePath.replace(/^\.\.\//, '');
  };
  setTimeout(shaderCanvas.setShader.bind(shaderCanvas, shader.source), 0);
  wrapper.appendChild(shaderCanvas.domElement);
  shaderCanvas.togglePause();

  function resize() {
    shaderCanvas.domElement.style = {}; // fall back to document style temporarily
    const style = window.getComputedStyle(shaderCanvas.domElement);
    const width = parseFloat(style.width);
    shaderCanvas.setSize(width, width);
  }
  window.addEventListener("resize", resize);

  const monitor = ScrollMonitor.create(shaderCanvas.domElement);
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

  function initShader() {
    resize();
    if (shaderCanvas.paused !== monitor.isInViewport) {
      shaderCanvas.togglePause();
    }
  }

  if (document.readyState === "complete") {
    setTimeout(initShader, 0);
  } else {
    window.addEventListener("load", initShader);
  }

  el.dispose = function() {
    console.log("dispose", shader.slug);
    window.removeEventListener("resize", resize);
    shaderCanvas.dispose();
    monitor.destroy();
  };

  return el;
}
