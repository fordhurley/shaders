const float PI = 3.14159;
const float TWOPI = 2.0 * PI;

  // Signed distance from point to radial line defined by equation:
  //    y = mx + b
float distanceFromLine(vec2 st, float m, float b) {
  return (st.x - m * st.y - b) / sqrt(1.0 + m*m);
}

float radialLine(vec2 st, float minR, float maxR, float a, float w) {
  float radiusSq = dot(st, st);

  // Make a ring:
  float v = step(minR*minR, radiusSq) - step(maxR*maxR, radiusSq);

  float d = distanceFromLine(st, tan(a), 0.0);
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

float radialDiamond(vec2 st, float r, float a, float w, float l) {
  // A diamond can be defined as the intersection of two distance fields,
  // crossing through a common center.

  float m = tan(a);
  vec2 c = vec2(r * cos(a), r * sin(a));

  // First line:
  // y = m x - m c.x + c.y
  float m1 = m - w/l;
  float b1 = c.y - m1 * c.x;
  float d = distanceFromLine(st, m1, b1);
  float edge = w*w/16.0 + l*l/4.0;
  float v = 1.0 - step(edge, d*d);

  // Second line:
  float m2 = m + w/l;
  float b2 = c.y - m2 * c.x;
  d = distanceFromLine(st, m2, b2);
  v *= 1.0 - step(edge, d*d);

  return v;
}

float radialDiamonds(vec2 st, float t, int numDiamonds) {
  float v = 0.0;
  const int NUM_LOOPS = 12;
  float w = 0.025 * smoothstep(0.0, 0.5, t) + 0.01;
  float l = 0.2;
  float r = smoothstep(0.0, 1.0, t) + l/2.0;
  for (int i = 0; i < NUM_LOOPS; i++) {
    if (i > numDiamonds) { break; }
    float a = float(i) * 2.0 * PI / float(numDiamonds);
    v += radialDiamond(st, r, a, w, 0.1);
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
    color += radialDiamonds(st, t, 10);
  }
  color = clamp(color, 0.0, 1.0);
  gl_FragColor = vec4(color, 1.0);
}
