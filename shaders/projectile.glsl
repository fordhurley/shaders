precision highp float;

#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)
#pragma glslify: map = require(../lib/map)

vec3 projectile(vec3 acceleration, vec3 pos0, vec3 vel0, float t) {
  vec3 position = pos0;
  position += vel0 * t;
  position += 0.5 * acceleration * t * t;
  return position;
}

// https://cl.ly/3u320h0T1o1O/projectile_with_drag.jpg
// except replacing `g` with `acceleration * mass`
vec3 projectileWithDrag(float drag, vec3 acceleration, float mass, vec3 pos0, vec3 vel0, float t) {
  float massOverDrag = mass / drag;
  vec3 position = pos0;
  position += massOverDrag * acceleration * t;
  position += massOverDrag * (massOverDrag * acceleration - vel0) * (exp(-t / massOverDrag) - 1.0);
  return position;
}

float circle(vec2 center, float radius, vec2 st) {
  float d = distance(center, st);
  return 1.0 - step(radius, d);
}

vec3 drawProjectile(vec3 bg, float drag, float mass, float t, vec2 uv) {
  const vec3 gravity = vec3(0.0, -1.0, 0.0);
  const vec3 pos0 = vec3(0.0);
  const vec3 vel0 = vec3(0.35, 1.3, 0.0);

  vec3 pos = projectile(gravity, pos0, vel0, t);
  if (drag > 0.01) {
    pos = projectileWithDrag(drag, gravity, mass, pos0, vel0, t);
  }

  float radius = map(mass, 0.5, 2.0, 0.01, 0.03);
  vec3 color = hsv2rgb(vec3(map(drag, 0.0, 4.0, 0.0, 0.75), 0.9, 1.0));

  float mask = 0.7 * circle(pos.xy, radius, uv);

  return mix(bg, color, mask);
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  float loopTime = 3.0;

  float loopIndex = floor(u_time / loopTime);
  float t = mod(u_time, loopTime);

  float mass = mod(loopIndex, 4.0) + 0.5;

  vec3 color = vec3(0.97);

  color = drawProjectile(color, 0.0, mass, t, uv);
  color = drawProjectile(color, 0.3, mass, t, uv);
  color = drawProjectile(color, 0.6, mass, t, uv);
  color = drawProjectile(color, 1.0, mass, t, uv);
  color = drawProjectile(color, 1.5, mass, t, uv);
  color = drawProjectile(color, 2.5, mass, t, uv);
  color = drawProjectile(color, 4.0, mass, t, uv);

  gl_FragColor = vec4(color, 1.0);
}
