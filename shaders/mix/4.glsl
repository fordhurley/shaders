precision mediump float;

#define sqrt2 1.414213562

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  float k;
  vec3 color;

  k = distance(uv, vec2(0.0, 1.0)) / sqrt2;
  color = mix(color, vec3(0.1, 0.1, 1.0), k);

  k = distance(uv, vec2(1.0, 1.0)) / sqrt2;
  color = mix(color, vec3(0.0, 0.6, 0.5), k);

  gl_FragColor = vec4(color, 1.0);
}
