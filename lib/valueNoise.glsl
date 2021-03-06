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

float valueNoise(vec2 st, vec2 period) {
  vec2 i = floor(st);
  vec2 f = fract(st);

  vec2 offset = vec2(0.0, 0.0);
  float v00 = dot(hash(mod(i + offset, period)), f - offset);
  offset = vec2(1.0, 0.0);
  float v10 = dot(hash(mod(i + offset, period)), f - offset);
  offset = vec2(0.0, 1.0);
  float v01 = dot(hash(mod(i + offset, period)), f - offset);
  offset = vec2(1.0, 1.0);
  float v11 = dot(hash(mod(i + offset, period)), f - offset);

  vec2 u = smoothstep(0.0, 1.0, f);

  float v0 = mix(v00, v10, u.x);
  float v1 = mix(v01, v11, u.x);

  float v = mix(v0, v1, u.y);

  return v;
}

#pragma glslify: export(valueNoise)
