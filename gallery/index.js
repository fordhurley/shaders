import "./style.scss";
import shaders from "./shaders";
import makeShaderElement from "./shader-element";

function init(shaderSlug) {
  const main = document.querySelector("main");

  while (main.firstChild) {
    const child = main.firstChild;
    if (child.dispose) {
      child.dispose();
    }
    main.removeChild(child);
  }

  if (!shaderSlug && window.location.hash) {
    shaderSlug = window.location.hash.slice(1);
  }

  let shader;
  if (shaderSlug) {
    shader = shaders.find(s => s.slug === shaderSlug);
    if (!shader) {
      console.warn("No shader found for:", shaderSlug);
    }
  }

  if (shader) {
    main.classList.add("solo");
    main.appendChild(makeShaderElement(shader, true));
  } else {
    shaders.forEach(function(shader) {
      main.appendChild(makeShaderElement(shader, false));
    });
  }
}

init();
