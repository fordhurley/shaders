#pragma glslify: map = require(../lib/map)
#pragma glslify: clamp01 = require(../lib/clamp01)

#pragma glslify: noise = require(glsl-noise/periodic/2d)

#define TWOPI 2.0 * 3.14159

float streaks(vec2 uv) {
  float theta = atan(uv.y, uv.x);
  theta /= TWOPI;

  const float offset = 0.123; // could be clock or random seed

  const int streakRepeat = 10;

  float v = noise(vec2(theta + offset) * float(streakRepeat), vec2(float(streakRepeat)));

  return step(0.0, v);
}

float dots(vec2 uv, vec2 gridSize) {
  // Gridded cell coordinate:
  vec2 cellNum = floor(uv * gridSize);

  // Coordinate within the cell:
  vec2 cellUV = fract(uv * gridSize);

  // Normalized radius for the cell:
  float radius = length(cellNum);
  radius /= max(gridSize.x, gridSize.y);
  radius = clamp01(radius);

  float dotRadius = map(radius, 0.0, 1.0, 0.6, 0.2);
  float cellRadius = distance(cellUV, vec2(0.5));
  return 1.0 - step(dotRadius, cellRadius);
}

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  const vec3 bgColor = vec3(0.165, 0.471, 0.765);
  const vec3 streakColor = vec3(0.42, 0.737, 0.835);
  const vec3 dotColor = vec3(0.71, 0.906, 0.992);

  vec3 color = bgColor;

  color = mix(color, streakColor, streaks(uv));

  vec2 gridSize = u_resolution / 40.0;
  color = mix(color, dotColor, dots(uv, gridSize));

  gl_FragColor = vec4(color, 1.0);
}
