#pragma glslify: colorizeSDF = require(../lib/colorizeSDF)

float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

float outline(float d, float w) {
  return 1.0 - step(w/2.0, d) - (1.0 - step(-w/2.0, d));
}


uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  float d = circleSDF(st, 0.5);

  // Move the mouse vertically to change the width of the outline:
  float w = u_mouse.y;
  vec3 shape = vec3(outline(d, w));

  // Move the mouse horizontally to show the field:
  vec3 field = colorizeSDF(d);
  vec3 color = mix(shape, field, 1.0 - u_mouse.x);

  gl_FragColor = vec4(color, 1.0);
}
