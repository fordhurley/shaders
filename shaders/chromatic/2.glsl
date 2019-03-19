precision mediump float;

#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)

#pragma glslify: map = require(../../lib/map)
#pragma glslify: hash = require(../../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

float circleGrid(vec2 uv, vec2 spacing) {
  float edgeWidth = 0.04;

  vec2 cellUV = mod(uv, 1.0 + spacing);

  float r = 2.0 * distance(cellUV, vec2(0.5));
  float ring = smoothstep(
    1.0 - edgeWidth,
    1.0,
    r
  );


  return ring;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  const float repeat = 5.0;
  uv += 0.5 / repeat;
  vec2 offset;
  vec2 spacing;

  vec3 color;

  spacing = vec2(0.0);
  offset = vec2(0.0);
  float grid = circleGrid(uv * repeat + offset, spacing);
  color += vec3(0.0, 0.0, 1.0) * grid;

  spacing = vec2(0.03);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color += vec3(1.0, 0.0, 0.0) * grid;

  spacing = vec2(0.06);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color += vec3(0.0, 1.0, 0.0) * grid;

  // color = 1.0 - color;

  gl_FragColor = vec4(color, 1.0);
}
