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
  vec2 d = center - st;
  float distanceSq = dot(d, d);
  if (distanceSq < radius * radius) {
    return 1.0;
  }
  return 0.0;
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  float loopTime = 2.5;

  vec3 gravity = vec3(0.0, -1.0, 0.0);
  float mass = 2.0;
  vec3 pos0 = vec3(0.0);
  vec3 vel0 = vec3(0.5, 1.3, 0.0);
  const float radius = 0.02;

  float t = mod(u_time, loopTime);

  vec3 color = vec3(0.0);

  vec3 position;
  position = projectile(gravity, pos0, vel0, t);
  color += vec3(1.0, 0.0, 0.0) * circle(position.xy, radius, uv);

  position = projectileWithDrag(0.5, gravity, mass, pos0, vel0, t);
  color += vec3(0.0, 1.0, 0.0) * circle(position.xy, radius, uv);

  position = projectileWithDrag(1.0, gravity, mass, pos0, vel0, t);
  color += vec3(0.0, 0.0, 1.0) * circle(position.xy, radius, uv);

  position = projectileWithDrag(2.0, gravity, mass, pos0, vel0, t);
  color += vec3(0.5, 0.0, 1.0) * circle(position.xy, radius, uv);

  position = projectileWithDrag(3.0, gravity, mass, pos0, vel0, t);
  color += vec3(0.0, 0.5, 1.0) * circle(position.xy, radius, uv);

  position = projectileWithDrag(4.0, gravity, mass, pos0, vel0, t);
  color += vec3(1.0, 0.0, 0.5) * circle(position.xy, radius, uv);

  gl_FragColor = vec4(color, 1.0);
}
