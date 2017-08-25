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

// Oriented vertically. Round caps at top and bottom. The top of the top cap
// will just touch (0, 1).
float drip(vec2 st, vec2 size) {
  float radius = size.x * 0.5;
  // The total height is radius + rectHeight + radius:
  float rectHeight = size.y - radius - radius;

  st.y -= 1.0;
  st.y += radius;
  float dCapTop = circle(st, radius);

  st.y += rectHeight * 0.5;
  float dRect = rect(st, vec2(size.x, rectHeight));

  st.y += rectHeight * 0.5;
  float dCapBottom = circle(st, radius);

  // Union the three shapes:
  float d = dCapTop;
  d = min(d, dRect);
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
  uv.x += (1.0 - aspect)/2.0;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  const float loopTime = 4.0;
  float t = fract(iGlobalTime / loopTime);
  float loopIndex = floor(iGlobalTime / loopTime);

  // t = 0.85; // for capturing stills

  const float noiseScale = 0.2;
  const float noiseFreq = 2.5;

  const float dripRadius = 0.25;
  const float maxDripRadius = dripRadius * (1.0 + noiseScale);
  const float dripHeightStart = 2.0 * dripRadius;
  // The shape will be distorted by (up to) noiseScale in all directions, so we
  // need to keep it shorter than the full height to keep it from clipping. This
  // allows for the extreme case where the top edge pushes up by noiseScale and
  // the bottom edge pushes down by noiseScale.
  const float dripHeightEnd = 2.0 - 2.0*noiseScale;
  // Similarly, we need to move everything down a little to avoid clipping at
  // the top edge:
  st.y += noiseScale;

  float noise = noiseScale * valueNoise(st * noiseFreq + loopIndex);
  st += noise;

  float dripHeight = mix(dripHeightStart, dripHeightEnd, t);
  float dist = drip(st, vec2(dripRadius*2.0, dripHeight));

  vec3 shape = vec3(1.0 - step(0.0, dist));

  // Negative parts are red / Positive parts are blue / Green is hard to for me
  // to see / So I don't use that color...
  vec3 field = vec3(0.0);
  if (dist < 0.0) {
    field.r = -dist;
  } else {
    field.b = dist;
  }

  // Move the mouse horizontally to visualize the field and the shape together.
  vec3 color = mix(shape, field, iMouse.x);

  vec2 dripBottomST = st;
  dripBottomST.y -= 1.0;
  dripBottomST.y += dripHeight - dripRadius;
  dripBottomST /= dripRadius; // normalize

  float radiusSq = dot(dripBottomST, dripBottomST);

  vec3 normal = vec3(0.0, 0.0, 1.0);
  if (radiusSq < 1.0) {
    normal = vec3(dripBottomST, sqrt(1.0 - radiusSq));
  }

  // Move the mouse vertically to visualize the normals.
  color = mix(color, normal, iMouse.y);

  gl_FragColor = vec4(color, 1.0);
}
