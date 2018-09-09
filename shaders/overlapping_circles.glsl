#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)

#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

float circleGrid(vec2 uv) {
  float lineWidth = 0.02;
  float edgeWidth = 0.02;

  vec2 cellNum = floor(uv);
  vec2 cellUV = fract(uv);

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

  const float repeat = 4.0;
  vec2 offset;

  vec3 color;

  offset = vec2(0.0);
  float grid = circleGrid(uv * repeat + offset);
  color = mix(color, vec3(1.0), grid);

  offset = vec2(0.5);
  grid = circleGrid(uv * repeat + offset);
  color = mix(color, vec3(1.0), grid);

  color = 1.0 - color;

  gl_FragColor = vec4(color, 1.0);
}
