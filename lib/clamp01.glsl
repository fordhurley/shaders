float clamp01(float x) {
  return clamp(x, 0.0, 1.0);
}

vec2 clamp01(vec2 x) {
  return clamp(x, 0.0, 1.0);
}

vec3 clamp01(vec3 x) {
  return clamp(x, 0.0, 1.0);
}

vec4 clamp01(vec4 x) {
  return clamp(x, 0.0, 1.0);
}

#pragma glslify: export(clamp01)
