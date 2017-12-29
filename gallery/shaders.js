import slugify from "slugify";

var shaders = [];

function registerShader(source, title) {
  shaders.push({
    source: source,
    title: title,
    slug: slugify(title),
  });
}

import uniform_noise from "../shaders/uniform_noise.glsl";
registerShader(uniform_noise, "uniform noise comparison");

import cloud from "../shaders/cloud.glsl";
registerShader(cloud, "cloud");

import rain from "../shaders/rain.glsl";
registerShader(rain, "rain");

import ray_march_drip from "../shaders/ray_march_drip.glsl";
registerShader(ray_march_drip, "drip");

import refract from "../shaders/refract.glsl";
registerShader(refract, "refract");

import ray_march from "../shaders/ray_march.glsl";
registerShader(ray_march, "ray march");

import flower2 from "../shaders/flower2.glsl";
registerShader(flower2, "flower2");

import flower from "../shaders/flower.glsl";
registerShader(flower, "flower");

import dots from "../shaders/dots.glsl";
registerShader(dots, "dots");

import cells from "../shaders/cells.glsl";
registerShader(cells, "cells");

import fabric from "../shaders/fabric.glsl";
registerShader(fabric, "fabric");

import directional_lighting from "../shaders/directional_lighting.glsl";
registerShader(directional_lighting, "directional lighting");

import projectile from "../shaders/projectile.glsl";
registerShader(projectile, "projectile");

export default shaders;
