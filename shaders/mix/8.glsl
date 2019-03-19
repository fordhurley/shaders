precision mediump float;

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(
    mix(0.2, 0.8, uv.x),
    mix(0.0, 0.7, uv.y),
    mix(0.2, 0.8, uv.y)
  );
  gl_FragColor = vec4(color, 1.0);
}
