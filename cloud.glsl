#pragma glslify: map = require(./lib/map)
#pragma glslify: noise = require(./lib/valueNoise)

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

vec3 cloud(vec2 st, float t) {
  vec2 q = vec2(0.0);
  q.x = fbm(st);
  q.y = fbm(st + 1.0);

  vec2 r = vec2(0.0);
  r.x = fbm(st + q + vec2(1.7, 9.2) + 0.15 * t);
  r.y = fbm(st + q + vec2(8.3, 2.8) + 0.13 * t);

  float f = fbm(st + r);

  vec3 color0 = vec3(0.1, 0.62, 0.67);
  vec3 color1 = vec3(0.67, 0.67, 0.5);
  vec3 color2 = vec3(0.0, 0.0, 0.16);
  vec3 color3 = vec3(0.67, 1.0, 1.0);

  vec3 color = mix(color0, color1, clamp01(f * f * 4.0));
  color = mix(color, color2, clamp01(length(q)));
  color = mix(color, color3, clamp01(r.x));

  return (f*f*f + 0.6*f*f + 0.5*f) * color;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time;
  float speed = 1.0;
  t *= speed;

  vec2 repeat = vec2(3.5);
  vec2 offset = vec2(12.5);
  uv = uv * repeat + offset;

  gl_FragColor = vec4(cloud(uv, t), 1.0);
}
