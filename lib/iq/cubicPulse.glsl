// From Inigo Quilez
// http://iquilezles.org/www/articles/functions/functions.htm

// Replacement for
// smoothstep(center-width, center, x) - smoothstep(center, center+width, x)
float cubicPulse(float center, float width, float x) {
    x = abs(x - center);
    if (x > width) {
      return 0.0;
    }
    x /= width;
    return 1.0 - x * x * (3.0 - 2.0*x);
}

#pragma glslify: export(cubicPulse)
