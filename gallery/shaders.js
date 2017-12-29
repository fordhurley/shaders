var shaders = [];

import uniform_noise from "../shaders/uniform_noise.glsl";
shaders.push({
  source: uniform_noise,
  title: "uniform noise comparison",
});

import cloud from "../shaders/cloud.glsl";
shaders.push({
  source: cloud,
  title: "cloud",
});

import rain from "../shaders/rain.glsl";
shaders.push({
  source: rain,
  title: "rain",
});

import ray_march_drip from "../shaders/ray_march_drip.glsl";
shaders.push({
  source: ray_march_drip,
  title: "drip",
});

import refract from "../shaders/refract.glsl";
shaders.push({
  source: refract,
  title: "refract",
});

import ray_march from "../shaders/ray_march.glsl";
shaders.push({
  source: ray_march,
  title: "ray march",
});

import flower2 from "../shaders/flower2.glsl";
shaders.push({
  source: flower2,
  title: "flower2",
});

import flower from "../shaders/flower.glsl";
shaders.push({
  source: flower,
  title: "flower",
});

import dots from "../shaders/dots.glsl";
shaders.push({
  source: dots,
  title: "dots",
});

import cells from "../shaders/cells.glsl";
shaders.push({
  source: cells,
  title: "cells",
});

import fabric from "../shaders/fabric.glsl";
shaders.push({
  source: fabric,
  title: "fabric",
});

import directional_lighting from "../shaders/directional_lighting.glsl";
shaders.push({
  source: directional_lighting,
  title: "directional lighting",
});

import projectile from "../shaders/projectile.glsl";
shaders.push({
  source: projectile,
  title: "projectile",
});

export default shaders;
