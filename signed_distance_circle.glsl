float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

float outline(float d, float w) {
  return 1.0 - step(w/2.0, d) - (1.0 - step(-w/2.0, d));
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  float d = circleSDF(st, 0.5);

  // Move the mouse vertically to change the width of the outline:
  float w = iMouse.y;
  vec3 shape = vec3(outline(d, w));

  // Negative parts are red / Positive parts are blue / Green is hard to for me
  // to see / So I don't use that color...
  vec3 field = vec3(0.0);
  if (d < 0.0) {
    field.r = -d;
  } else {
    field.b = d;
  }

  // Move the mouse horizontally to show the field:
  vec3 color = mix(shape, field, iMouse.x);

  gl_FragColor = vec4(color, 1.0);
}
