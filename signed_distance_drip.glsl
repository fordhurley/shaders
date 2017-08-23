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

  vec3 shape = vec3(1.0 - step(0.0, d));

    // Negative parts are red / Positive parts are blue / Green is hard to for me
    // to see / So I don't use that color...
  vec3 field = vec3(0.0);
  if (d < 0.0) {
    field.r = -d;
  } else {
    field.b = d;
  }

  // Move the mouse horizontally to visualize the field and the shape together.
  vec3 color = mix(shape, field, iMouse.x);

  gl_FragColor = vec4(color, 1.0);
}
