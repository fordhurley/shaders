#pragma glslify: map = require(../../lib/map)
#pragma glslify: hash = require(../../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

float circleGrid(vec2 uv, vec2 spacing) {
  float lineWidth = 0.02;
  float edgeWidth = 0.02;

  vec2 cellUV = mod(uv, spacing);

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

  vec2 offset;
  const float repeat = 6.0;
  vec2 spacing = vec2(1.0);

  vec3 color;

  offset = vec2(0.0);
  float grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(1.0), grid);

  offset = vec2(0.5);
  grid = circleGrid(uv * repeat + offset, spacing);
  color = mix(color, vec3(1.0), grid);

  color = 1.0 - color;

  gl_FragColor = vec4(color, 1.0);
}
