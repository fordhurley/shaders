precision mediump float;

#pragma glslify: clamp01 = require(../../lib/clamp01)

#define sqrt2 1.414213562

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  float k;
  vec3 color = vec3(1);

  float maxDist = sqrt2;

  k = maxDist - distance(uv, vec2(0.0, 1.0));
  k = clamp01(k);
  color -= k * vec3(1, 0, 0);

  k = maxDist - distance(uv, vec2(0.0, 0.0));
  k = clamp01(k);
  color -= k * vec3(0, 1, 0);

  k = maxDist - distance(uv, vec2(1.0, 0.0));
  k = clamp01(k);
  color -= k * vec3(0, 0, 1);

  gl_FragColor = vec4(color, 1.0);
}
