float circle(vec2 st, float radius) {
  return length(st) - radius;
}

// Comment out to show the shape:
#define SHOW_FIELD

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 color = vec3(0.0);

  float d = circle(st, 0.5);
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
