const float PI = 3.14159;
const float TWOPI = 2.0 * PI;

  // Signed distance from point to radial line defined by equation:
  //    y = mx + b
float distanceFromLine(vec2 st, float m, float b) {
  return (st.x - m * st.y - b) / sqrt(1.0 + m*m);
}

mat4 translationMatrix(vec3 t) {
  return mat4(1.0, 0.0, 0.0, 0.0,
              0.0, 1.0, 0.0, 0.0,
              0.0, 0.0, 1.0, 0.0,
              t.x, t.y, t.z, 1.0);
}

mat4 rotationMatrix(vec3 axis, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;
  // https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
  return mat4(c + axis.x*axis.x*oc, axis.y*axis.x*oc + axis.z*s, axis.z*axis.x*oc - axis.y*s, 0.0,
              axis.x*axis.y*oc - axis.z*s, c + axis.y*axis.y*oc, axis.z*axis.y*oc + axis.x*s, 0.0,
              axis.x*axis.z*oc - axis.y*s, axis.y*axis.z*oc - axis.x*s, c + axis.z*axis.z*oc, 0.0,
              0.0, 0.0, 0.0, 1.0);
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

float diamond(vec2 st, float w, float h) {
  // A diamond can be defined as the intersection of two distance fields,
  // crossing through a common center.

  float m = w/h;
  float b = 0.0;

  float d1 = distanceFromLine(st, m, b);
  float d2 = distanceFromLine(st, -m, b);

  // The edge distance is the "altitude" of the right triangle formed by one
  // quadrant of the diamond.
  // https://en.wikipedia.org/wiki/Right_triangle#Altitudes
  // TODO: OPTIMIZE compare to squared distance.
  float edge = (w*h/4.0) / sqrt(w*w/4.0 + h*h/4.0);

  float v = 1.0 - step(edge, abs(d1));
  v *= 1.0 - step(edge, abs(d2));

  return v;
}

float radialDiamond(vec2 st, float r, float a, float w, float h) {
  vec3 t = vec3(0.0, r, 0.0);
  vec3 zAxis = vec3(0.0, 0.0, 1.0);
  mat4 transformation = translationMatrix(t) * rotationMatrix(zAxis, -a - PI/2.0);
  vec4 stPrime = transformation * vec4(st, 0.0, 1.0);
  return diamond(stPrime.xy, w, h);
}

float radialDiamonds(vec2 st, float t, int numDiamonds) {
  float v = 0.0;
  const int NUM_LOOPS = 10;
  float w = 0.15 * smoothstep(0.25, 1.0, t) + 0.02;
  float h = 0.25 * smoothstep(0.0, 0.5, t);
  float r = 2.0 * smoothstep(0.25, 1.0, t) + h/2.0;
  for (int i = 0; i < NUM_LOOPS; i++) {
    if (i > numDiamonds) { break; }
    float a = float(i) * 2.0 * PI / float(numDiamonds);
    v += radialDiamond(st, r, a, w, h);
  }
  return clamp(v, 0.0, 1.0);
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  vec2 st = uv * 2.0 - 1.0;

  const float loopTime = 1.9;
  float t = mod(iGlobalTime, loopTime);
  t /= loopTime;

  int loopIndex = int(mod(iGlobalTime / loopTime, 2.0));

  vec3 color = vec3(0.25, 0.0, 0.0);
  // if (loopIndex == 0) {
    // color += radialLines(st, t, 8);
  // } else if (loopIndex == 1) {
    color += radialDiamonds(st, t, 10);
  // }
  color = clamp(color, 0.0, 1.0);
  gl_FragColor = vec4(color, 1.0);
}
