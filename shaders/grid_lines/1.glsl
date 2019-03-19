precision highp float;

#pragma glslify: cubicPulse = require(../../lib/iq/cubicPulse)
#pragma glslify: map = require(../../lib/map)

#define PI 3.14159

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  uv.x += 0.025 * sin(4.0 * PI * uv.y + u_time);
  uv.y += 0.025 * sin(4.0 * PI * uv.x + u_time);

  const vec2 gridSize = vec2(8.0);

  // Gridded cell coordinate:
  vec2 cellNum = floor(uv * gridSize);

  // Coordinate within the cell:
  vec2 cellUV = fract(uv * gridSize);

  float lineWidth = 0.1;

  float alpha = cubicPulse(0.5, lineWidth, cellUV.x);
  alpha = max(alpha, cubicPulse(0.5, lineWidth, cellUV.y));

  vec3 color = vec3(0.0);
  color = mix(color, vec3(1.0), alpha);

  gl_FragColor = vec4(color, 1.0);
}
