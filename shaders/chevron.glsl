precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define sqrt2 1.4142

// TODO: lineSpacing

float chevron(vec2 uv, float lineWidth) {
  vec2 st = fract(uv);
  // Mirror every other cell horizontally:
  st.x = abs(mod(floor(uv.x), 2.0) - st.x);
  float line = st.x + st.y;
  line = fract(line + lineWidth * 0.5);
  return step(lineWidth, line);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  float repeat = 20.0 * clamp(0.25, 0.75, u_mouse.y);
  uv *= repeat;

  float lineWidth = clamp(0.01, 0.99, u_mouse.x);
  vec3 color = vec3(1.0) * chevron(uv, lineWidth);

  gl_FragColor = vec4(color, 1.0);
}
