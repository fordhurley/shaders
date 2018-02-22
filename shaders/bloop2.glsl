#pragma glslify: gradient = require(../lib/gradient)
#pragma glslify: hash = require(../lib/hash)
#pragma glslify: impulse = require(../lib/iq/impulse)
#pragma glslify: map = require(../lib/map)
#pragma glslify: smoothUnion = require(../lib/iq/smoothUnion)

float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

float randomDot(vec2 st, float t, float index) {
  vec3 seed = vec3(hash(vec2(index)));
  seed.y = hash(seed.xy + 12.329);
  seed.z = hash(seed.yz * PI);

  float angle = 2.0 * PI * seed.x;
  float scale = mix(0.1, 0.15, seed.y);
  float speed = mix(1.5, 2.0, seed.z);

  vec2 center = vec2(
    t * t * speed * cos(angle),
    t * t * speed * sin(angle)
  );
  float radius = scale * impulse(1.2, t);

  return circleSDF(st - center, radius);
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;

  vec2 st = map(uv, 0.0, 1.0, -1.0, 1.0);

  float loopTime = 4.0;
  float t = fract(u_time / loopTime);
  float loopIndex = floor(u_time / loopTime);

  float d = randomDot(st, t, loopIndex);
  for (int i = 1; i < 50; i++) {
    float dotIndex = loopIndex + float(i) * 142.8;
    d = smoothUnion(d, randomDot(st, t, dotIndex), 0.1);
  }

  float v = d;
  v += length(uv) * 0.1;

  vec3 bg = gradient(st, vec3(0.0, 0.4, 0.5), vec3(0.0, 0.2, 0.8), vec2(-1, 1), vec2(1, 0.75));
  vec3 fg = vec3(0.9, 0.95, 0.95);

  const float edgeWidth = 0.01;
  float alpha = 1.0 - smoothstep(-edgeWidth/2.0, edgeWidth/2.0, v);
  vec3 color = mix(bg, fg, alpha);

  gl_FragColor = vec4(color, 1.0);
}
