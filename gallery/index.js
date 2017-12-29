import scrollMonitor from "scrollmonitor";
import ShaderCanvas from "shader-canvas";
import slugify from "slugify";

import "./style.scss";

const MAX_SIZE = 600;

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

function makeShader(shader, title) {
  const slug = slugify(title);

  const el = document.createElement("div");
  el.classList.add("shader");

  const metaTop = document.createElement("div");
  metaTop.classList.add("meta");
  metaTop.classList.add("top");
  el.appendChild(metaTop);
  metaTop.innerHTML = `
    <span>${title}</span>
    <a class="source hidden" href="javascript:">source</a>
  `;

  const wrapper = document.createElement("div");
  wrapper.classList.add("canvas-wrapper");
  wrapper.id = "shader-${slug}"
  el.appendChild(wrapper);

  const source = document.createElement("pre");
  source.classList.add("shader-source");
  source.classList.add("hidden");
  source.textContent = shader;
  wrapper.appendChild(source);

  const sourceButton = metaTop.querySelector(".source");
  sourceButton.addEventListener("click", function(e) {
    e.preventDefault();
    source.classList.toggle("hidden");
  });

  const shaderCanvas = new ShaderCanvas();
  shaderCanvas.buildTextureURL = function(filePath) {
    // ../textures/foo.jpg -> textures/foo.jpg
    return filePath.replace(/^\.\.\//, '');
  };
  shaderCanvas.setShader(shader);
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

import uniform_noise from "../shaders/uniform_noise.glsl";
main.appendChild(makeShader(uniform_noise, "uniform noise comparison"));

import cloud from "../shaders/cloud.glsl";
main.appendChild(makeShader(cloud, "cloud"));

import rain from "../shaders/rain.glsl";
main.appendChild(makeShader(rain, "rain"));

import ray_march_drip from "../shaders/ray_march_drip.glsl";
main.appendChild(makeShader(ray_march_drip, "drip"));

import refract from "../shaders/refract.glsl";
main.appendChild(makeShader(refract, "refract"));

import ray_march from "../shaders/ray_march.glsl";
main.appendChild(makeShader(ray_march, "ray march"));

import flower2 from "../shaders/flower2.glsl";
main.appendChild(makeShader(flower2, "flower2"));

import flower from "../shaders/flower.glsl";
main.appendChild(makeShader(flower, "flower"));

import dots from "../shaders/dots.glsl";
main.appendChild(makeShader(dots, "dots"));

import cells from "../shaders/cells.glsl";
main.appendChild(makeShader(cells, "cells"));

import fabric from "../shaders/fabric.glsl";
main.appendChild(makeShader(fabric, "fabric"));

import directional_lighting from "../shaders/directional_lighting.glsl";
main.appendChild(makeShader(directional_lighting, "directional lighting"));

import projectile from "../shaders/projectile.glsl";
main.appendChild(makeShader(projectile, "projectile"));
