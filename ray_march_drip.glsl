uniform sampler2D tex; // ./textures/nyc_night.jpg
uniform sampler2D texBlurred; // ./textures/nyc_night_blur.jpg

#define EPSILON 1e-4

// map x from [a1, a2] to [b1, b2]
float map(float x, float a1, float a2, float b1, float b2) {
  return b1 + (b2 - b1) * (x - a1) / (a2 - a1);
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

float unionSDF(float a, float b) {
  return min(a, b);
}

float subtractSDF(float a, float b) {
  return max(a, -b);
}

// polynomial smooth min
// http://iquilezles.org/www/articles/smin/smin.htm
float smoothUnion(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// This is a 3D distance field, but it just extends in z to negative infinity
// (positive z is outside the shape).
float rectSDF(vec3 p, vec2 size) {
  vec2 d = abs(p.xy) - size/2.0;
  // d is negative on the inside, so take the more positive, which is the
  // distance to the closest edge:
  float inside = max(d.x, d.y);
  // d is positive outside, so the max(d, 0) zeros any components that are
  // inside, e.g. when vertically above the box we only care about the y
  // distance. When we're fully outside (diagonally) the box, this is the
  // length from the nearest corner.
  float outside = length(max(d, 0.0));
  float dist = min(inside, 0.0) + outside;
  dist = max(dist, p.z);
  return dist;
}

// Similar to rectSDF, this also produces a 3D SDF, but will be shaped like a
// cylinder parallel to the z axis, that extends from z = [0, -inf].
float circleSDF(vec3 p, float radius) {
  float dist = length(p.xy) - radius;
  return max(dist, p.z);
}

float sphereSDF(vec3 p, float radius) {
  return length(p) - radius;
}

// Head of the drip will be centered at p.
float dripSDF(vec3 p, float r, float h, float noiseScale, float noiseFreq, float noiseSeed) {
  p.y -= h;

  float noise = noiseScale * valueNoise(p.xy * noiseFreq + noiseSeed);
  p.xy += noise;

  float d = circleSDF(p, r);
  d = unionSDF(d, rectSDF(p + vec3(0.0, h/2.0, 0.0), vec2(2.0*r, h)));
  // Put another disk on the back, for better merging with the blob
  d = unionSDF(d, circleSDF(p + vec3(0.0, h, 0.0), r));

  float blob = subtractSDF(sphereSDF(p + vec3(0.0, h, 0.0), r), p.z);
  d = smoothUnion(d, blob, 0.1); // TODO: k proportional to r
  return d;
}

float dripHeight(float t) {
  return 1.5*t;
}

vec3 dripHead(float t) {
  float h = dripHeight(t);
  return vec3(0.0, 0.75 - h, 0.0);
}

float sceneSDF(vec3 p, float t, float seed) {
  float r = 0.15;
  float h = dripHeight(t);
  float noiseScale = 0.13;
  float noiseFreq = 20.0 * noiseScale;

  p -= dripHead(t);

  float d = dripSDF(p, r, h, noiseScale, noiseFreq, seed);
  return d;
}

// Ray marching from
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions
float depth(vec3 eyePos, vec3 viewDir, float maxDepth, float t, float seed) {
  float depth = 0.0;
  for (int i = 0; i < 255; i++) {
    vec3 p = eyePos + depth * viewDir;
    float dist = sceneSDF(p, t, seed);
    if (dist < EPSILON) {
      // We're inside the scene surface!
      return depth;
    }
    // Move along the view ray
    depth += dist;

    if (depth >= maxDepth) {
      // Gone too far; give up
      return maxDepth;
    }
  }
  return maxDepth;
}

vec3 normal(vec3 p, float t, float seed) {
  vec3 n = vec3(0.0);
  n.x = sceneSDF(vec3(p.x + EPSILON, p.y, p.z), t, seed) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z), t, seed);
  n.y = sceneSDF(vec3(p.x, p.y + EPSILON, p.z), t, seed) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z), t, seed);
  n.z = sceneSDF(vec3(p.x, p.y, p.z + EPSILON), t, seed) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON), t, seed);
  return normalize(n);
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;
  uv.x += (1.0 - aspect)/2.0;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 eyePos = vec3(st, 1.5); // Needs to be far enough in z to be outside
  vec3 viewDir = vec3(0.0, 0.0, -1.0); // Orthogonal projection
  float maxDepth = 2.0;

  const float loopTime = 4.0;
  float t = fract(iGlobalTime / loopTime);
  float loopIndex = floor(iGlobalTime / loopTime);

  float d = depth(eyePos, viewDir, maxDepth, t, loopIndex);

  vec3 pointOnSurface = eyePos + viewDir * d;
  vec3 normalOnSurface = normal(pointOnSurface, t, loopIndex);

  vec2 clearUV = uv;
  vec3 refraction = refract(viewDir, normalOnSurface, 0.5);
  float distanceToBackground = 0.75;
  clearUV.x += -distanceToBackground * refraction.x / refraction.z;
  clearUV.y += -distanceToBackground * refraction.y / refraction.z;
  vec3 clearColor = texture2D(tex, clearUV).rgb;

  vec3 foggyColor = texture2D(texBlurred, uv).rgb;
  float fogFrequenccy = 5.0;
  float fogNoise = valueNoise(uv * fogFrequenccy);
  fogNoise += 0.5 * valueNoise(uv * fogFrequenccy * 2.0);
  float fogOpacity = map(fogNoise, -1.0, 1.0, 0.1, 0.2);
  foggyColor = mix(foggyColor, vec3(1.0), fogOpacity);

  // Foggy if we didn't hit the surface:
  float fogginess = step(maxDepth-EPSILON, d);
  float wetness = 1.0 - fogginess;
  wetness -= 1.5 * distance(st, dripHead(t).xy) * map(2.0*valueNoise(8.0 * (st + loopIndex)), -1.0, 1.0, 0.0, 1.0);
  wetness = clamp(wetness, 0.0, 1.0);
  vec3 color = mix(foggyColor, clearColor, wetness);

  gl_FragColor = vec4(color, 1.0);
}
