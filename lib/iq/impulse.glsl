// From Inigo Quilez
// http://iquilezles.org/www/articles/functions/functions.htm
//
// Great for triggering behaviours or making envelopes for music or animation,
// and for anything that grows fast and then slowly decays.
//
// Use k to control the stretching of the function. Btw, it's maximum, which is
// 1.0, happens at exactly x = 1/k.
float impulse(float k, float x) {
  float h = k * x;
  return h * exp(1.0-h);
}

#pragma glslify: export(impulse)
