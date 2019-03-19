precision highp float;

#pragma glslify: noise = require('glsl-noise/simplex/4d')

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

float sphereSDF(vec3 p, float radius) {
  return length(p) - radius;
}

float sceneSDF(vec3 p) {
  float radius = 0.5;
  radius += 0.17 * noise(vec4(p, u_time));
  float d = sphereSDF(p, radius);
  return d;
}

// Ray marching from
// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions
float depth(vec3 eyePos, vec3 viewDir, float maxDepth) {
  const float epsilon = 1e-6;
  float depth = 0.0;
  for (int i = 0; i < 255; i++) {
    vec3 p = eyePos + depth * viewDir;
    float dist = sceneSDF(p);
    if (dist < epsilon) {
      // We're inside the scene surface!
      return depth;
    }
    // Move along the view ray
    depth += dist;

    if (depth >= maxDepth) {
      // Gone too far; give up
      break;
    }
  }
  return -1.0;
}

vec3 normal(vec3 p) {
  const float epsilon = 1e-3;
  return normalize(vec3(
    sceneSDF(vec3(p.x + epsilon, p.y, p.z)) - sceneSDF(vec3(p.x - epsilon, p.y, p.z)),
    sceneSDF(vec3(p.x, p.y + epsilon, p.z)) - sceneSDF(vec3(p.x, p.y - epsilon, p.z)),
    sceneSDF(vec3(p.x, p.y, p.z  + epsilon)) - sceneSDF(vec3(p.x, p.y, p.z - epsilon))
  ));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect; // maintain aspect ratio
  uv.x += (1.0 - aspect)/2.0; // center horizontally

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 eyePos = vec3(st, 1.0); // Needs to be far enough in z to be outside
  vec3 viewDir = vec3(0.0, 0.0, -1.0); // Orthogonal projection
  float maxDepth = 2.0;

  float d = depth(eyePos, viewDir, maxDepth);

  vec3 color = vec3(0.0); // clear color

  if (d > -0.5) {
    // Hit the surface.

    color = vec3(0.0, 0.0, 0.1); // ambient light

    vec3 pointOnSurface = eyePos + viewDir * d;
    vec3 normalOnSurface = normal(pointOnSurface);

    vec3 lightPos = vec3(-1.0, 1.0, 1.0);
    if (u_mouse.x > 0.0 && u_mouse.y > 0.0) {
      lightPos.xy = u_mouse * 2.0 - 1.0;
    }
    vec3 lightDir = normalize(-lightPos);

    const vec3 lightColor = vec3(0.5);
    vec3 light = lightColor * vec3(dot(normalOnSurface, -lightDir));
    light = clamp(light, 0.0, 1.0);
    color += light; // directional light
  }

  gl_FragColor = vec4(color, 1.0);
}
