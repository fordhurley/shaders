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

float circle(vec2 st, float radius) {
  return length(st) - radius;
}

// Oriented vertically. Round caps at top and bottom. The entire shape is
// centered on (0, 0).
float drip(vec2 st, vec2 size) {
  // The total height is radius + rectHeight + radius, where the radius is half
  // the width.
  float rectHeight = size.y - size.x;
  // If the size is wider than it is tall, we end up with a circle.
  rectHeight = max(rectHeight, 0.0);

  float dRect = rect(st, vec2(size.x, rectHeight));
  float dCapTop = circle(st + vec2(0.0, rectHeight/2.0), size.x/2.0);
  float dCapBottom = circle(st - vec2(0.0, rectHeight/2.0), size.x/2.0);

  // Union the three shapes:
  float d = dRect;
  d = min(d, dCapTop);
  d = min(d, dCapBottom);
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

  const float noiseScale = 0.2;
  const float noiseFreq = 2.0;

  const float dripRadius = 0.25;
  const float maxDripRadius = dripRadius * (1.0 + noiseScale);
  const vec2 dripStart = vec2(0.0, 1.0 - maxDripRadius);
  const vec2 dripEnd = vec2(0.0, -1.0 + maxDripRadius);

  const float dripHeightStart = 2.0 * dripRadius;
  const float dripHeightEnd = 2.0; // Full height
  float dripHeight = mix(dripHeightStart, dripHeightEnd, t);
  vec2 dripPos = mix(dripStart, dripEnd, t);

  vec2 dripST = st - vec2(0.0, 1.0 - dripHeight/2.0);

  float d = drip(dripST, vec2(dripRadius*2.0, dripHeight));

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
