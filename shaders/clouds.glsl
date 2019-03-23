precision mediump float;

#pragma glslify: map = require(../lib/map)
#pragma glslify: gain = require(../lib/iq/gain)
#pragma glslify: noise = require(glsl-noise/classic/3d)

float clamp01(float x) {
  return clamp(x, 0.0, 1.0);
}

vec3 clamp01(vec3 v) {
  return clamp(v, 0.0, 1.0);
}

// https://thebookofshaders.com/13/

float fbm(vec3 p) {
  float value = 0.0;
  float amplitude = 0.5;
  vec3 shift = vec3(100.0);
  // Rotate to reduce axial bias
  mat3 rotation = mat3(
    cos(0.5), sin(0.5), 0.0,
    -sin(0.5), cos(0.5), 0.0,
    0.0, 0.0, 1.0
  );
  for (int i = 0; i < 4; i++) {
    value += amplitude * map(noise(p), -1.0, 1.0, 0.0, 1.0);
    p = rotation * p;
    p *= 2.0;
    p += shift;
    amplitude *= 0.5;
  }
  return value;
}

vec4 cloud(vec3 p, float t) {
  vec3 q = vec3(0.0);
  q.x = fbm(p);
  q.y = fbm(p + 1.0);

  vec3 r = vec3(0.0);
  r.x = fbm(p + q + vec3(1.7, 9.2, 3.1) - 0.05 * t);
  r.y = fbm(p + q + vec3(8.3, 2.8, 5.4) + 0.03 * t);

  float f = fbm(p + r);

  vec3 color = vec3(0.0);
  color = mix(color, vec3(0.4, 0.4, 0.8), clamp01(length(q)));
  color = mix(color, vec3(1.0), clamp01(1.5 * r.x));
  color = clamp01(color);

  float alpha = gain(f, 9.0);
  alpha = clamp01(alpha);

  return vec4(color, alpha);
}

vec3 skyGradient(vec2 uv) {
  vec3 bg = vec3(0.012, 0.6, 0.741);
  vec3 fg = vec3(0.314, 0.686, 0.894);

  float k = uv.y;
  k *= map(noise(vec3(uv, 1.5)), -1.0, 1.0, 0.0, 1.5);
  k = clamp01(k);
  return mix(bg, fg, k);
}

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time;
  t *= 4.0;

  vec3 color = skyGradient(uv + vec2(0.01 * t, 0.0));

  vec2 repeat = vec2(2.0, 10.0);
  vec2 offset = vec2(15.0);

  float scrollSpeed = 0.04;
  offset.x += t * scrollSpeed;

  vec2 st = uv * repeat + offset;
  vec3 p = vec3(st, u_mouse.x / u_resolution.x);

  float warpSpeed = 0.3;
  vec4 cloudColor = cloud(p, t * warpSpeed);

  // Fade top to bottom:
  cloudColor.a *= map(uv.y, 0.2, 0.7, 0.0, 1.0);
  cloudColor.a = clamp01(cloudColor.a);

  color = mix(color, cloudColor.rgb, cloudColor.a);

  gl_FragColor = vec4(color, 1.0);
}
