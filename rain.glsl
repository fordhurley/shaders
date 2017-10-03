uniform sampler2D noiseTex; // textures/noise.png
uniform sampler2D bgTex; // textures/nyc_night_blur.jpg


vec2 vec2Random(vec2 st) {
  st = vec2(dot(st, vec2(0.040,-0.250)),
  dot(st, vec2(269.5,183.3)));
  return -1.0 + 2.0 * fract(sin(st) * 43758.633);
}

float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = smoothstep(0.0, 1.0, f);

    return mix(mix(dot(vec2Random(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
                   dot(vec2Random(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(vec2Random(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
                   dot(vec2Random(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
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
  alpha *= raininess;
  alpha = clamp(alpha, 0.0, 1.0);
  return alpha;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec3 color = texture2D(bgTex, uv).rgb;
  color += 0.1;
  vec3 rainColor = vec3(0.0);

  float speed = 1.0;
  float t = iGlobalTime;
  t *= speed;

  float raininess = 0.15;
  float rainAlpha = rain(uv, t, raininess, 0.2);
  rainAlpha += rain(uv * 2.0 + 2.0, t, raininess, 0.1);
  rainAlpha = clamp(rainAlpha, 0.0, uv.y + 0.25); // fade at the bottom
  rainAlpha *= 0.5; // fade overall

  color = mix(color, rainColor, rainAlpha);

  gl_FragColor = vec4(color, 1.0);
}
