precision mediump float;

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(
    mix(-0.1, 0.6, -0.02 * uv.x + uv.y),
    0.0,
    mix(-0.2, 0.6, uv.x + 0.2 * uv.y)
  );
  color = clamp(color, 0.0, 1.0);
  color += 0.55 * (1.0 - uv.x);
  gl_FragColor = vec4(color, 1.0);
}
