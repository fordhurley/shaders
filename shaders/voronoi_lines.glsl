#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

// Based on Inigo's article:
// http://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm
float voronoiBorder(vec2 uv) {
  const vec2 repeat = vec2(5.0);
  vec2 cellNum = floor(uv * repeat);
  vec2 cellUV = fract(uv * repeat);

  float minDSq = 8.0;
  vec2 minNeighbor;
  vec2 minDelta;
  for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
      vec2 neighbor = vec2(x, y);
      vec2 center = vec2(
        hash(cellNum + neighbor),
        hash(cellNum + neighbor + 32.134)
      );
      center += neighbor;
      vec2 delta = center - cellUV;
      float dSq = dot(delta, delta);
      if (dSq < minDSq) {
        minDSq = dSq;
        minNeighbor = neighbor;
        minDelta = delta;
      }
    }
  }

  minDSq = 8.0;
  for (int x = -2; x <= 2; x++) {
    for (int y = -2; y <= 2; y++) {
      vec2 neighbor = minNeighbor + vec2(x, y);
      vec2 center = vec2(
        hash(cellNum + neighbor),
        hash(cellNum + neighbor + 32.134)
      );
      center += neighbor;
      vec2 delta = center - cellUV;
      if (dot(minDelta-delta, minDelta-delta) > 1e-6) {
        float dSq = dot(
          0.5 * (minDelta + delta),
          normalize(delta - minDelta)
        );
        minDSq = min(minDSq, dSq);
      }
    }
  }

  float lineWidth = 0.01;
  float edgeWidth = sqrt2 / u_resolution.x;
  float lineMask = smoothstep(lineWidth, lineWidth + edgeWidth, minDSq);
  return 1.0 - lineMask;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  vec3 color = vec3(1.0);
  float lineMask = voronoiBorder(uv);
  color = mix(color, vec3(0.0), lineMask);

  gl_FragColor = vec4(color, 1.0);
}
