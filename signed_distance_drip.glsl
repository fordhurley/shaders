// Oriented vertically (round cap is at the bottom, centered at 0, 0), and
// infinitely tall.
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

vec2 vec2Random(vec2 st) {
  st = vec2(dot(st, vec2(0.040,-0.250)),
  dot(st, vec2(269.5,183.3)));
  return -1.0 + 2.0 * fract(sin(st) * 43758.633);
}

float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = smoothstep(0.0, 1.0, f);

    return mix(mix(dot(vec2Random(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
                   dot(vec2Random(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(vec2Random(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
                   dot(vec2Random(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  const float loopTime = 4.0;
  float t = fract(iGlobalTime / loopTime);
  float loopIndex = floor(iGlobalTime / loopTime);

  const float dripRadius = 0.5;
  vec2 dripPos = vec2(0.0, 0.0);
  dripPos.y = mix(1.0, -1.0 + dripRadius, t);

  float d = drip(st - dripPos, dripRadius);

  const float noiseScale = 0.2;
  const float noiseFreq = 2.0;
  d += noiseScale * valueNoise(st * noiseFreq + loopIndex);

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
