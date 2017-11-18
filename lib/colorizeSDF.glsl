// Negative parts are red
// Positive parts are blue
// Green is hard to for me to see
// ... so I don't use that color.

vec3 colorizeSDF(float d) {
  vec3 color = vec3(0.0);
  color.r -= d * (1.0 - step(0.0, d));
  color.b += d * step(0.0, d);
  return color;
}

#pragma glslify: export(colorizeSDF)
