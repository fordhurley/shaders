// From Inigo Quilez
// http://iquilezles.org/www/articles/functions/functions.htm

// Replacement for
// smoothstep(center-width/2, center, x) - smoothstep(center, center+width/2, x)
float cubicPulse(float center, float width, float x) {
  x = abs(x - center);
  float halfWidth = width * 0.5;
  if (x > halfWidth) {
    return 0.0;
  }
  x /= halfWidth;
  return 1.0 - x * x * (3.0 - 2.0*x);
}

#pragma glslify: export(cubicPulse)
