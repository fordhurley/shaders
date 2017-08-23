float rect(vec2 st, vec2 size) {
  vec2 d = abs(st) - size/2.0;
  // d is negative on the inside, so take the more positive, which is the
  // distance to the closest edge:
  float inside = max(d.x, d.y);
  // d is positive outside, so the max(d, 0) zeros any components that are
  // inside, e.g. when vertically above the box we only care about the y
  // distance. When we're fully outside (diagonally) the box, this is the
  // length from the nearest corner.
  float outside = length(max(d, 0.0));
  return min(inside, 0.0) + outside;
}

// Comment out to show the shape:
#define SHOW_FIELD

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 color = vec3(0.0);

  float d = rect(st, vec2(1.0, 0.5));
  color += 1.0 - step(0.0, d);

  #ifdef SHOW_FIELD
    color = vec3(0.0);
    if (d < 0.0) {
      color.r -= d; // Negative parts are red
    } else {
      color.b += d; // Positive parts are blue
    }
  #endif

  gl_FragColor = vec4(color, 1.0);
}
