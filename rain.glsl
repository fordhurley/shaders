uniform sampler2D noiseTex; // textures/noise.png

float rain(vec2 uv, float t, float raininess) {
  // Tilt:
  uv.x += uv.y * 0.2;

  // Stretch vertically, to make streaks:
  float streakLength = 150.0;
  uv.y /= streakLength;

  // Move rain down by moving uv up:
  uv.y += t * 0.1;

  float alpha = texture2D(noiseTex, fract(uv)).r;
  alpha /= raininess;
  alpha *= alpha;
  alpha = 1.0 - alpha;
  return alpha;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec3 color = vec3(0.46, 0.46, 0.55);
  vec3 rainColor = color + 0.25;

  float speed = 1.0;
  float t = iGlobalTime;
  t *= speed;

  float raininess = 0.15;
  float rainAlpha = rain(uv, t, raininess);
  rainAlpha = clamp(rainAlpha, 0.0, uv.y + 0.25); // fade at the bottom
  rainAlpha *= 0.5; // fade overall

  color = mix(color, rainColor, rainAlpha);

  gl_FragColor = vec4(color, 1.0);
}
