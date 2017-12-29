#pragma glslify: valueNoise = require("../lib/valueNoise")
#pragma glslify: map = require("../lib/map")

#define PI 3.14159

float rain(vec2 uv, float t, float raininess, float slant) {
  // Tilt:
  uv.x += uv.y * slant;

  // Stretch vertically, to make streaks:
  float streakLength = 150.0;
  uv.y /= streakLength;

  // Move rain down by moving uv up:
  float speed = 0.1;
  uv.y += t * speed;

  uv *= 100.0;

  float alpha = valueNoise(uv);
  alpha -= clamp(0.5 - raininess, 0.0, 1.0);
  alpha *= raininess;
  alpha = clamp(alpha, 0.0, 1.0);
  return alpha;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec3 color = vec3(0.2, 0.3, map(uv.y, 0.0, 1.0, 0.5, 0.4));
  vec3 rainColor = vec3(0.87, 0.87, 0.91);

  float t = iGlobalTime;
  float loopTime = 8.0;

  float raininess = map(sin(t * 2.0 * PI / loopTime), -1.0, 1.0, 0.15, 0.4);
  float rainAlpha = rain(uv, t, raininess, 0.2);
  rainAlpha += rain(uv * 2.0 + 2.0, t, raininess, 0.1);
  rainAlpha = clamp(rainAlpha, 0.0, 1.0);
  rainAlpha *= uv.y + 0.1; // fade at the bottom
  rainAlpha *= 0.85; // fade overall

  color = mix(color, rainColor, rainAlpha);

  gl_FragColor = vec4(color, 1.0);
}
