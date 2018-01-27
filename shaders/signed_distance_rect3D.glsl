#pragma glslify: colorizeSDF = require(../lib/colorizeSDF)

float rectSDF(vec3 p, vec2 size) {
  vec2 d = abs(p.xy) - size/2.0;
  // d is negative on the inside, so take the more positive, which is the
  // distance to the closest edge:
  float inside = max(d.x, d.y);
  // d is positive outside, so the max(d, 0) zeros any components that are
  // inside, e.g. when vertically above the box we only care about the y
  // distance. When we're fully outside (diagonally) the box, this is the
  // length from the nearest corner.
  float outside = length(max(d, 0.0));
  float dist = min(inside, 0.0) + outside;
  dist = max(dist, p.z);
  return dist;
}

// Comment out to show the shape:
#define SHOW_FIELD

uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 color = vec3(0.0);

  vec3 p = vec3(st, 0.0);
  p.z = u_mouse.x * 2.0 - 1.0; // [-1, 1]
  float d = rectSDF(p, vec2(1.0, 0.5));
  color += 1.0 - step(0.0, d);

  #ifdef SHOW_FIELD
    color = colorizeSDF(d);
  #endif

  gl_FragColor = vec4(color, 1.0);
}
