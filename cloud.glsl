#pragma glslify: map = require(./lib/map)
#pragma glslify: noise = require(./lib/valueNoise)
#pragma glslify: gain = require(./lib/iq/gain)

float clamp01(float x) {
  return clamp(x, 0.0, 1.0);
}

// https://thebookofshaders.com/13/

float fbm(vec2 st) {
  float value = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rotation = mat2(
    cos(0.5), sin(0.5),
    -sin(0.5), cos(0.5)
  );
  for (int i = 0; i < 5; i++) {
    value += amplitude * map(noise(st), -1.0, 1.0, 0.0, 1.0);
    st = rotation * st;
    st *= 2.0;
    st += shift;
    amplitude *= 0.5;
  }
  return value;
}

vec4 cloud(vec2 st, float t) {
  vec2 q = vec2(0.0);
  q.x = fbm(st);
  q.y = fbm(st + 1.0);

  vec2 r = vec2(0.0);
  r.x = fbm(st + q + vec2(1.7, 9.2) + 0.15 * t);
  r.y = fbm(st + q + vec2(8.3, 2.8) + 0.13 * t);

  float f = fbm(st + r);

  vec3 color = vec3(1.0);
  color = mix(color, vec3(0.7), clamp01(length(q)));
  color = mix(color, vec3(0.9), clamp01(r.x));

  float alpha = gain(f, 12.0);
  alpha = clamp01(alpha);

  return vec4(color, alpha);
}

vec3 skyGradient(vec2 uv) {
  vec3 bg = vec3(0.012, 0.6, 0.741);
  vec3 fg = vec3(0.314, 0.686, 0.894);

  float k = uv.y;
  k *= map(noise(uv), -1.0, 1.0, 0.0, 1.5);
  k = clamp01(k);
  return mix(bg, fg, k);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time;
  t *= 4.0;

  vec3 color = skyGradient(uv + vec2(0.01 * t, 0.0));

  vec2 repeat = vec2(2.0, 10.0);
  vec2 offset = vec2(15.0);

  float scrollSpeed = 0.07;
  offset.x += t * scrollSpeed;

  vec2 st = uv * repeat + offset;

  float warpSpeed = 0.5;
  vec4 cloudColor = cloud(st, t * warpSpeed);

  cloudColor.a *= map(uv.y, 0.2, 1.0, 0.0, 1.4);
  cloudColor.a = clamp01(cloudColor.a);

  color = mix(color, cloudColor.rgb, cloudColor.a);

  gl_FragColor = vec4(color, 1.0);
}
