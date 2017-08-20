const float PI = 3.14159;
const float TWOPI = 2.0 * PI;

float radialLine(vec2 st, float minR, float maxR, float a, float w) {
  float radius = length(st);

  // Make a ring:
  float v = step(minR, radius) - step(maxR, radius);

  // Signed distance from point to radial line defined by equation:
  //    y - tanA * x = 0
  float tanA = tan(a);
  float d = st.x - tanA * st.y;
  d /= sqrt(1.0 + tanA*tanA);

  v *= step(-0.5*w, d) - step(0.5*w, d);

  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  vec2 st = uv * 2.0 - 1.0;

  const float loopTime = 1.2;
  float t = iGlobalTime;
  // t /= 4.0; // slow mo
  t = mod(t, loopTime);
  t /= loopTime;

  float innerRadius = smoothstep(0.0, 1.0, t);
  float outerRadius = smoothstep(0.0, 0.7, t);
  float lineWidth = 0.1 * smoothstep(0.0, 1.0, t);

  vec3 color = vec3(0.25, 0.0, 0.0);

  const int numLines = 10;
  for (int i = 0; i < numLines/2; i++) {
    float a = float(i) * 2.0 * PI / float(numLines);
    color += radialLine(st, innerRadius, outerRadius, a, lineWidth);
  }

  color = clamp(color, 0.0, 1.0);

  gl_FragColor = vec4(color, 1.0);
}
