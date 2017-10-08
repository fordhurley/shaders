#pragma glslify: noise = require(glsl-noise/simplex/2d)
#pragma glslify: map = require(./lib/map)

// https://thebookofshaders.com/13/

float fbm(vec2 st) {
  float v = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rot = mat2(
    cos(0.5), sin(0.5),
    -sin(0.5), cos(0.5)
  );
  for (int i = 0; i < 4; i++) {
    v += amplitude * noise(st);
    st = rot * st;
    st *= 2.0;
    st += shift;
    amplitude *= 0.5;
  }
  return v;
}

float cloud(vec2 st, float t) {
  vec2 q = vec2(0.0);
  q.x = fbm(st);
  q.y = fbm(st + 1.0);

  vec2 r = vec2(0.0);
  r.x = fbm(st + q + vec2(1.7, 9.2) + t);
  r.y = fbm(st + q + vec2(8.3, 2.8) + t);

  float f = fbm(st + r);
  return f*f*f + 0.6*f*f + 0.5*f;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time;
  float speed = 0.1;
  t *= speed;

  uv *= 1.3;

  vec3 color = vec3(0.0);

  vec3 cloudColor = vec3(1.0);
  float cloudAlpha = cloud(uv, t);
  color = mix(color, cloudColor, cloudAlpha);

  gl_FragColor = vec4(color, 1.0);
}
