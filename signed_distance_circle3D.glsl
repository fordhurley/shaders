#pragma glslify: colorizeSDF = require(./lib/colorizeSDF)

float circleSDF(vec3 p, float radius) {
  float dist = length(p.xy) - radius;
  return max(dist, p.z);
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 p = vec3(st, 0.0);
  // Move mouse vertically to change z:
  p.z = iMouse.y * 2.0 - 1.0;

  float d = circleSDF(p, 0.5);
  vec3 shape = vec3(1.0 - step(0.0, d));

  vec3 field = colorizeSDF(d);

  // Move mouse horizontally to visualize field:
  vec3 color = mix(shape, field, iMouse.x);

  gl_FragColor = vec4(color, 1.0);
}
