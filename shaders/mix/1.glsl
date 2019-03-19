precision mediump float;

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  gl_FragColor = vec4(uv.x, 0.0, uv.y, 1.0);
}
