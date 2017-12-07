#pragma glslify: map = require(./lib/map)
#pragma glslify: clamp01 = require(./lib/clamp01)
#pragma glslify: valueNoise = require(./lib/valueNoise)
#pragma glslify: cubicPulse = require(./lib/iq/cubicPulse)

#pragma glslify: noise = require(glsl-noise/periodic/2d)

#define TWOPI 2.0 * 3.14159

#define ANIMATION_LOOP_TIME 2.0

float streaks(vec2 uv, float t) {
  float theta = atan(uv.y, uv.x);
  theta /= TWOPI;

  const float offset = 0.123; // could be clock or random seed

  const int streakRepeat = 10;

  float v = noise(vec2(theta + offset) * float(streakRepeat), vec2(float(streakRepeat)));

  // const float pulseDuration = 0.1;
  // float pulseCenter = ANIMATION_LOOP_TIME - pulseDuration;
  //
  // t = mod(t, ANIMATION_LOOP_TIME);
  // float threshold = cubicPulse(pulseCenter, pulseDuration, t);
  // threshold = map(threshold, 0.0, 1.0, 0.1, -0.03);
  // return step(threshold, v);

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

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  const vec3 bgColor = vec3(0.165, 0.471, 0.765);
  const vec3 streakColor = vec3(0.42, 0.737, 0.835);
  const vec3 dotColor = vec3(0.71, 0.906, 0.992);

  vec3 color = bgColor;

  float t = u_time;
  color = mix(color, streakColor, streaks(uv, t));

  vec2 gridSize = u_resolution / 40.0;
  color = mix(color, dotColor, dots(uv, gridSize));

  gl_FragColor = vec4(color, 1.0);
}
