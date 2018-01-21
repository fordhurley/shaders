#pragma glslify: clamp01 = require(../../lib/clamp01)

#define sqrt2 1.414213562

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  float k;
  vec3 color;

  k = distance(uv, vec2(0.0, 0.5));
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.796, 0.612, 1), k);

  k = distance(uv, vec2(0.5, 1.0));
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(1, 0.988, 0.616), k);

  k = distance(uv, vec2(1.0, 0.0));
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.62, 0.82, 1), k);

  gl_FragColor = vec4(color, 1.0);
}
