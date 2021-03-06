precision highp float;

#pragma glslify: colorizeSDF = require(../lib/colorizeSDF)

// #define DEBUG // comment to show the final image

uniform sampler2D tex; //  ../textures/nyc_night.jpg
uniform sampler2D texBlurred; //  ../textures/nyc_night_blur.jpg

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
// Return value is (nx, ny, nz, d)
vec4 dripNormalAndDist(vec2 st, vec2 size) {
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

  // Normalize st so it reaches 1 at the center of the bottom cap (where our
  // blob of water is):
  st /= radius;

  float rSquared = dot(st, st);

  vec3 normal = vec3(0.0, 0.0, 1.0);
  if (rSquared < 1.0) {
    normal = vec3(st, sqrt(1.0 - rSquared));
  }

  return vec4(normal, d);
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

float fog(vec2 uv) {
  float fogFrequency = 5.0;
  float fogNoise = valueNoise(uv * fogFrequency);
  fogNoise += 0.5 * valueNoise(uv * fogFrequency * 2.0);
  return 0.5 + 0.5 * fogNoise; // ~[0, 1]
}

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += (1.0 - aspect)/2.0;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  const float loopTime = 9.0;
  float t = fract(u_time / loopTime);
  float loopIndex = floor(u_time / loopTime);

  // For capturing stills:
  // t = 0.85;
  // loopIndex = 4.0;

  const float noiseScale = 0.2;
  const float noiseFreq = 2.5;

  const float dripRadius = 0.25;
  const float maxDripRadius = dripRadius * (1.0 + noiseScale);
  const float dripHeightStart = 2.0 * dripRadius;
  // The shape will be distorted by (up to) noiseScale in all directions, so we
  // need to keep it shorter than the full height to keep it from clipping. This
  // allows for the extreme case where the top edge pushes up by noiseScale and
  // the bottom edge pushes down by noiseScale.
  const float dripHeightEnd = 5.0;
  // Similarly, we need to move everything down a little to avoid clipping at
  // the top edge:
  // st.y += noiseScale;
  st.y -= 0.5;

  float noise = noiseScale * valueNoise(st * noiseFreq + loopIndex);
  st += noise;

  float dripHeight = mix(dripHeightStart, dripHeightEnd, t);
  vec2 dripSize = vec2(dripRadius*2.0, dripHeight);

  vec4 normalAndDist = dripNormalAndDist(st, dripSize);
  vec3 normal = normalAndDist.xyz;
  float dist = normalAndDist.w;

  vec3 shape = vec3(1.0 - step(0.0, dist));

  vec3 field = colorizeSDF(dist);

  #ifdef DEBUG
    // Move the mouse horizontally to visualize the field and the shape together.
    vec3 color = mix(shape, field, u_mouse.x / u_resolution.x);
    // Move the mouse vertically to visualize the normals.
    color = mix(color, normal, u_mouse.y / u_resolution.y);
  #else
    vec3 view = vec3(0.0, 0.0, -1.0);
    vec3 refraction = refract(view, normal, 0.5);
    const float distanceToBackground = 0.5;
    uv.x += -distanceToBackground * refraction.x / refraction.z;
    uv.y += -distanceToBackground * refraction.y / refraction.z;
    uv = fract(uv);

    vec3 clearColor = texture2D(tex, uv).rgb;
    vec3 foggyColor = texture2D(texBlurred, uv).rgb;
    foggyColor = mix(foggyColor, vec3(1.0), 0.25*fog(uv));

    if (dist < 0.01) {
      dist += 0.5 * (st.y - 1.0 + 3.0*t);
      dist -= t * 0.3 * valueNoise(st * 12.0 + loopIndex);
      dist -= t * 0.1 * valueNoise(st * 20.0 + loopIndex);
    }
    // shape = vec3(-st.y + 0.5);
    float mixture = smoothstep(-0.02, 0.0, dist);
    vec3 color = mix(clearColor, foggyColor, mixture);
  #endif

  gl_FragColor = vec4(color, 1.0);
}
