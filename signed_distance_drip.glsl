// Oriented vertically (round cap is at the bottom).
float drip(vec2 st, float radius) {
  float left = -st.x - radius;
  float right = st.x - radius;
  float bottom = -st.y;
  float circle = length(st) - radius;

  float d = max(left, right);
  d = max(d, bottom);
  d = min(d, circle);
  return d;
}

// Comment out to show the shape:
#define SHOW_FIELD

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  const float loopTime = 2.0;
  float t = fract(iGlobalTime / loopTime);

  const float dripRadius = 0.5;
  vec2 dripPos = vec2(0.0, 0.0);
  dripPos.y = mix(1.0, -1.0 + dripRadius, t);

  float d = drip(st - dripPos, dripRadius);

  vec3 color = vec3(0.0);
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
