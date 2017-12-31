import slugify from "slugify";

var shaders = [];

function registerShader(source, raw_source, title) {
  shaders.push({
    source: source,
    raw_source: raw_source,
    title: title,
    slug: slugify(title),
  });
}

import flower2 from "../shaders/flower2.glsl";
import flower2_raw from "!raw-loader!../shaders/flower2.glsl";
registerShader(flower2, flower2_raw, "flower2");

import flower from "../shaders/flower.glsl";
import flower_raw from "!raw-loader!../shaders/flower.glsl";
registerShader(flower, flower_raw, "flower");

import dots from "../shaders/dots.glsl";
import dots_raw from "!raw-loader!../shaders/dots.glsl";
registerShader(dots, dots_raw, "dots");

import clouds from "../shaders/clouds.glsl";
import clouds_raw from "!raw-loader!../shaders/clouds.glsl";
registerShader(clouds, clouds_raw, "clouds");

import rain from "../shaders/rain.glsl";
import rain_raw from "!raw-loader!../shaders/rain.glsl";
registerShader(rain, rain_raw, "rain");

import ray_march_drip from "../shaders/ray_march_drip.glsl";
import ray_march_drip_raw from "!raw-loader!../shaders/ray_march_drip.glsl";
registerShader(ray_march_drip, ray_march_drip_raw, "drip");

import refract from "../shaders/refract.glsl";
import refract_raw from "!raw-loader!../shaders/refract.glsl";
registerShader(refract, refract_raw, "refract");

import ray_march from "../shaders/ray_march.glsl";
import ray_march_raw from "!raw-loader!../shaders/ray_march.glsl";
registerShader(ray_march, ray_march_raw, "ray march");

import cells from "../shaders/cells.glsl";
import cells_raw from "!raw-loader!../shaders/cells.glsl";
registerShader(cells, cells_raw, "cells");

import fabric from "../shaders/fabric.glsl";
import fabric_raw from "!raw-loader!../shaders/fabric.glsl";
registerShader(fabric, fabric_raw, "fabric");

import directional_lighting from "../shaders/directional_lighting.glsl";
import directional_lighting_raw from "!raw-loader!../shaders/directional_lighting.glsl";
registerShader(directional_lighting, directional_lighting_raw, "directional lighting");

import projectile from "../shaders/projectile.glsl";
import projectile_raw from "!raw-loader!../shaders/projectile.glsl";
registerShader(projectile, projectile_raw, "projectiles");

export default shaders;
