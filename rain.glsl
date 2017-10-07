uniform sampler2D noiseTex; // textures/noise.png

vec2 hash(vec2 st) {
  st = vec2(dot(st, vec2(0.040, -0.250)), dot(st, vec2(269.5, 183.3)));
  return fract(sin(st) * 43758.633) * 2.0 - 1.0;
}

float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float v00 = dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float v10 = dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float v01 = dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float v11 = dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    vec2 u = smoothstep(0.0, 1.0, f);

    float v0 = mix(v00, v10, u.x);
    float v1 = mix(v01, v11, u.x);

    float v = mix(v0, v1, u.y);

    return v;
}

float map(float value, float inMin, float inMax, float outMin, float outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

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

  vec3 color = vec3(0.3, 0.38, map(uv.y, 0.0, 1.0, 0.6, 0.5));
  vec3 rainColor = vec3(0.87, 0.87, 0.91);

  float t = iGlobalTime;

  float raininess = map(sin(t / 2.0), -1.0, 1.0, 0.15, 0.4);
  float rainAlpha = rain(uv, t, raininess, 0.2);
  rainAlpha += rain(uv * 2.0 + 2.0, t, raininess, 0.1);
  rainAlpha = clamp(rainAlpha, 0.0, 1.0);
  rainAlpha *= uv.y + 0.1; // fade at the bottom
  rainAlpha *= 0.85; // fade overall

  color = mix(color, rainColor, rainAlpha);

  gl_FragColor = vec4(color, 1.0);
}
