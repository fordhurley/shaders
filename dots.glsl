#pragma glslify: map = require('./lib/map')

#define PI 3.14149
#define ALL_ONES vec2(1.0)

float pattern(const vec2 st, float t) {
  const int numOctaves = 3;

  float v = 0.0;
  float f = 1.0;
  float edge = map(t, 0.0, 1.0, -1.0, 1.0);

  for (int i = 0; i < numOctaves; i++) {
    v += step(edge, dot(cos(st * 2.0 * PI * f), ALL_ONES) * 0.5);
    f *= 2.0;
  }
  v /= float(numOctaves);

  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += (1.0 - aspect)/2.0;

  float t = u_time;
  float loopTime = 12.0;
  t = mod(t, loopTime) / loopTime;
  t = smoothstep(0.0, 0.5, t) - smoothstep(0.5, 1.0, t);
  t = map(t, 0.0, 1.0, 0.0125, 0.9875);

  vec2 st = map(uv, 0.0, 1.0, -1.0, 1.0);

  float repeat = 3.0;
  st *= repeat;

  float v = pattern(st, t);
  vec3 color = mix(
    vec3(0.9, 0.9, 0.9),
    vec3(0.0, 0.0, 0.7),
    v
  );

  gl_FragColor = vec4(color, 1.0);
}
