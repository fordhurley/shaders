#define EPSILON 1e-6

float sphereSDF(vec3 p, float radius) {
  return length(p) - radius;
}

float sceneSDF(vec3 p) {
  float d = sphereSDF(p, 0.5);
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
  uv.x *= aspect; // maintain aspect ratio
  uv.x += (1.0 - aspect)/2.0; // center horizontally

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 eyePos = vec3(st, 1.0); // Needs to be far enough in z to be outside
  vec3 viewDir = vec3(0.0, 0.0, -1.0); // Orthogonal projection
  float maxDepth = 2.0;

  float d = depth(eyePos, viewDir, maxDepth);

  vec3 color = vec3(0.0); // clear color

  if (d < maxDepth - EPSILON) {
    // Hit the surface.

    color = vec3(0.0, 0.0, 0.1); // ambient light

    vec3 pointOnSurface = eyePos + viewDir * d;
    vec3 normalOnSurface = normal(pointOnSurface);

    vec3 lightPos = vec3(0.0, 0.0, 1.0);
    lightPos.xy = iMouse * 2.0 - 1.0;
    vec3 lightDir = normalize(-lightPos);

    const vec3 lightColor = vec3(0.5);
    vec3 light = lightColor * vec3(dot(normalOnSurface, -lightDir));
    light = clamp(light, 0.0, 1.0);
    color += light; // directional light
  }

  gl_FragColor = vec4(color, 1.0);
}
