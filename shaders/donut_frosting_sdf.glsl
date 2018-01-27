// Building a mask to be used on a torus to look like frosting on a donut. The
// torus will have uv arranged so that u is longitudinal (around the outer
// circumference), and v is around the "tube" with 0 and 1 at the bottom. The
// frosting is centered around v=0.5, and the melty edge runs parallel to u.

// In this WIP attempt, I'm trying to get a signed distance field for the
// frosting, which I could then used to calculate normals. So far, it isn't
// working.

#pragma glslify: valueNoise = require(../lib/valueNoise)
#pragma glslify: colorizeSDF = require(../lib/colorizeSDF)

#define EPSILON 1e-6

float edge(float x, float start, float meltiness, float repeat) {
  return start + meltiness * valueNoise(vec2(x*repeat));
}

// https://stackoverflow.com/a/26902185/576932
float distanceToLine(vec2 p1, vec2 p2, vec2 point) {
    float a = p1.y - p2.y;
    float b = p2.x - p1.x;
    return (a*point.x + b*point.y + p1.x*p2.y - p2.x*p1.y) / sqrt(a*a + b*b);
}

float distanceToEdge(vec2 uv, float startY, float meltiness, float repeat) {
  vec2 edge0 = vec2(uv.x - EPSILON, 0.0);
  edge0.y = edge(edge0.x, startY, meltiness, repeat);

  vec2 edge1 = vec2(uv.x + EPSILON, 0.0);
  edge1.y = edge(edge1.x, startY, meltiness, repeat);

  return distanceToLine(edge0, edge1, uv);
}

float distanceToFrosting(vec2 uv, float meltiness, float topEdge, float bottomEdge,
              float topRepeat, float bottomRepeat) {
  float distanceToTop = distanceToEdge(uv, topEdge, meltiness, topRepeat);
  float distanceToBottom = distanceToEdge(uv, bottomEdge, meltiness, bottomRepeat);

  return max(distanceToTop, -distanceToBottom);
}

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  const float meltiness = 0.01;
  const float topEdge = 0.75;
  const float bottomEdge = 0.25;
  const float topRepeat = 30.0;
  const float bottomRepeat = 20.0;

  float dist = distanceToFrosting(uv, meltiness, topEdge, bottomEdge,
                                  topRepeat, bottomRepeat);

  vec3 color = colorizeSDF(dist);
  color = vec3(1.0) * (1.0 - step(0.0, dist));

  gl_FragColor = vec4(color, 1.0);
}
