const float PI = 3.14159;
const float TWOPI = 2.0 * PI;

float radialLine(vec2 st, float minR, float maxR, float a, float w) {
  float radiusSq = dot(st, st);

  // Make a ring:
  float v = step(minR*minR, radiusSq) - step(maxR*maxR, radiusSq);

  // Signed distance from point to radial line defined by equation:
  //    y - tanA * x = 0
  float tanA = tan(a);
  float d = st.x - tanA * st.y;
  d /= sqrt(1.0 + tanA*tanA);

  v *= step(-0.5*w, d) - step(0.5*w, d);

  return v;
}

float radialLines(vec2 st, float t, int numLines) {
  float v = 0.0;
  const int NUM_LOOPS = 6;
  float innerRadius = smoothstep(0.0, 1.0, t);
  float outerRadius = smoothstep(0.0, 0.7, t);
  float lineWidth = 0.1 * smoothstep(0.0, 1.0, t);
  for (int i = 0; i < NUM_LOOPS; i++) {
    if (i > numLines/2) { break; }
    float a = float(i) * 2.0 * PI / float(numLines);
    v += radialLine(st, innerRadius, outerRadius, a, lineWidth);
  }
  return clamp(v, 0.0, 1.0);
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  vec2 st = uv * 2.0 - 1.0;

  const float loopTime = 1.2;
  float t = mod(iGlobalTime, loopTime);
  t /= loopTime;

  int loopIndex = int(mod(iGlobalTime / loopTime, 2.0));

  vec3 color = vec3(0.25, 0.0, 0.0);
  if (loopIndex == 0) {
    color += radialLines(st, t, 8);
  } else if (loopIndex == 1) {
    color += radialLines(st, t, 10);
  }
  color = clamp(color, 0.0, 1.0);
  gl_FragColor = vec4(color, 1.0);
}
