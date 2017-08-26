#define EPSILON 1e-3

float unionSDF(float a, float b) {
  return min(a, b);
}

float subtractSDF(float a, float b) {
  return max(a, -b);
}

// polynomial smooth min
// http://iquilezles.org/www/articles/smin/smin.htm
float smin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

float boxSDF(vec3 p, vec3 size) {
  vec3 d = abs(p) - size/2.0;
  // d is negative on the inside, so take the more positive, which is the
  // distance to the closest edge:
  float inside = max(max(d.x, d.y), d.z);
  // d is positive outside, so the max(d, 0) zeros any components that are
  // inside, e.g. when vertically above the box we only care about the y
  // distance. When we're fully outside (diagonally) the box, this is the
  // length from the nearest corner.
  float outside = length(max(d, 0.0));
  return min(inside, 0.0) + outside;
}

float rectSDF(vec3 p, vec2 size) {
  float box = boxSDF(p, vec3(size, EPSILON));
  return max(box, p.z);
}

float sphereSDF(vec3 p, float radius) {
  return length(p) - radius;
}

float diskSDF(vec3 p, float radius) {
  float sphere = sphereSDF(p, radius);
  return max(sphere, p.z);
}

float sceneSDF(vec3 p) {
  const float loopTime = 4.0;
  float t = fract(iGlobalTime / loopTime);

  // t = 1.0; // for still captures 

  float r = 0.25;
  float h = 1.0 * t;

  p.y -= 0.5;

  float d = diskSDF(p, r);
  d = unionSDF(d, rectSDF(p + vec3(0.0, h/2.0, 0.0), vec2(2.0*r, h)));
  // Put another disk on the back, for better merging with the semisphere
  d = unionSDF(d, diskSDF(p + vec3(0.0, h, 0.0), r));

  float semisphere = subtractSDF(sphereSDF(p + vec3(0.0, h, 0.0), r), p.z);

  d = smin(d, semisphere, 0.1);
  return d;
}

// Ray marching from
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions
float depth(vec3 eyePos, vec3 viewDir, float maxDepth) {
  float depth = 0.0;
  for (int i = 0; i < 255; i++) {
    vec3 p = eyePos + depth * viewDir;
    float dist = sceneSDF(p);
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

vec3 normal(vec3 p) {
  return normalize(vec3(
    sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
    sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
    sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
  ));
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

  float d = depth(eyePos, viewDir, maxDepth);

  vec3 pointOnSurface = eyePos + viewDir * d;
  vec3 normalOnSurface = normal(pointOnSurface);

  vec3 lightPos = vec3(0.0, 0.0, 1.5);
  lightPos.xy = iMouse * 2.0 - 1.0;

  vec3 lightDir = pointOnSurface - lightPos;
  float lightDistance = length(lightDir);
  lightDir = normalize(lightDir);

  vec3 color = vec3(0.0);
  if (d < maxDepth - EPSILON) {
    float lightIntensity = dot(normalOnSurface, -lightDir);
    lightIntensity /= lightDistance; // linear fall off
    lightIntensity = clamp(lightIntensity, 0.0, 1.0);

    vec3 lightColor = vec3(1);
    color = lightColor * lightIntensity;

    vec3 ambientLight = vec3(0.05, 0.05, 0.15);
    color += ambientLight;
  }

  gl_FragColor = vec4(color, 1.0);
}
