// From Inigo Quilez
// http://iquilezles.org/www/articles/functions/functions.htm

float gain(float x, float k) {
  float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
  return (x<0.5)?a:1.0-a;
}

#pragma glslify: export(gain)
