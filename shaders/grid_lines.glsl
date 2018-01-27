#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  const vec2 gridSize = vec2(15.0);

  // Gridded cell coordinate:
  vec2 cellNum = floor(uv * gridSize);

  // Coordinate within the cell:
  vec2 cellUV = fract(uv * gridSize);

  // Make the lineWidth a fixed number of pixels:
  vec2 cellResolution = u_resolution / gridSize;
  float lineWidth = 3.0 / cellResolution.y;

  float v = cubicPulse(0.5, lineWidth, cellUV.x);
  v = max(v, cubicPulse(0.5, lineWidth, cellUV.y));
  vec3 color = vec3(v);

  gl_FragColor = vec4(color, 1.0);
}
