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
  float ring = 1.0 - smoothstep(
    1.0 - 2.0 * edgeWidth,
    1.0 - edgeWidth,
    r
  );

  return ring;
}

float ringGrid(vec2 uv, vec2 spacing) {
  float lineWidth = 0.01;
  float edgeWidth = 0.03;

  vec2 cellUV = mod(uv, 1.0 + spacing);

  float r = 2.0 * distance(cellUV, vec2(0.5));
  float ring = smoothstep(
    1.0 - lineWidth - 2.0 * edgeWidth,
    1.0 - lineWidth - edgeWidth,
    r
  ) - smoothstep(
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

  vec3 color = vec3(1.0);

  spacing = vec2(0.15);
  offset = vec2(0.0);
  float grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.973, 0.855, 0.451), grid);
  grid = ringGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.0), grid);

  spacing = vec2(0.12);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.773, 0.596, 0.725), grid);
  grid = ringGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.0), grid);

  spacing = vec2(0.09);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.588, 0.796, 0.78), grid);
  grid = ringGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.0), grid);

  spacing = vec2(0.06);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.992, 0.663, 0.365), grid);
  grid = ringGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.0), grid);

  spacing = vec2(0.03);
  offset = vec2(0.0);
  grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.455, 0.588, 0.745), grid);
  grid = ringGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(0.0), grid);

  gl_FragColor = vec4(color, 1.0);
}
