const float PI = 3.14159;
const float TWOPI = 2.0 * PI;

struct Polar {
  float r;
  float a;
};

Polar toPolar(vec2 st) {
  float radius = length(st);
  float angle = atan(st.y, st.x);
  angle = mod(angle, TWOPI);
  return Polar(radius, angle);
}

// TODO: make edges parallel?
float radialLine(Polar p, float minR, float maxR, float a, float w) {
  float v = step(minR, p.r) - step(maxR, p.r);

  // TODO: deal with the wrap around at PI=0 and PI=2PI
  float minA = a - 0.5 * w;
  float maxA = a + 0.5 * w;

  v *= step(minA, p.a) - step(maxA, p.a);
  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  vec2 st = uv * 2.0 - 1.0;
  Polar polar = toPolar(st);

  const float loopTime = 1.2;
  float t = mod(iGlobalTime, loopTime);
  t /= loopTime;

  float innerRadius = smoothstep(0.0, 1.0, t);
  float outerRadius = smoothstep(0.0, 0.75, t);
  float lineWidth = 0.1;

  vec3 color = vec3(0.0);

  const int num = 12;
  for (int i = 0; i < num; i++) {
    float a = float(i) * 2.0 * PI / float(num);
    color += radialLine(polar, innerRadius, outerRadius, a, lineWidth);
  }

  gl_FragColor = vec4(color, 1.0);
}
