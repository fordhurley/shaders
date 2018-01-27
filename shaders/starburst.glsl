#pragma glslify: valueNoise = require("../lib/valueNoise")
#pragma glslify: map = require('../lib/map')

// Remapping the unit interval into the unit interval by expanding the sides and
// compressing the center, and keeping 1/2 mapped to 1/2.
//
// Values of k < 1 push everything towards 0.5.
// Values of k > 1 push everything away from 0.5.
//
// http://iquilezles.org/www/articles/functions/functions.htm
float gain(float x, float k) {
  float a = 0.5 * pow(2.0*((x<0.5)?x:1.0-x), k);
  return (x<0.5)?a:1.0-a;
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;

  uv = map(uv, 0.0, 1.0, -1.0, 1.0);
  uv.y += 1.2;

  float r = length(uv);
  float theta = atan(uv.y, uv.x);
  theta = map(theta, 0.0, 6.28, 0.0, 1.0);

  r /= 2.0;
  theta *= 45.0;


  float v = map(valueNoise(vec2(r, theta - u_time)), -1.0, 1.0, 0.0, 1.0);
  v += map(valueNoise(vec2(r * 1.0, theta * 2.0 - u_time) + 12.392), -1.0, 1.0, 0.0, 0.5);
  v /= 1.5;

  v = gain(v, 2.4);

  vec3 bg = vec3(0.0, 0.2, 0.0);
  vec3 fg = vec3(0.0, 0.8, 0.0);
  vec3 color = mix(bg, fg, v);

  gl_FragColor = vec4(color, 1.0);
}
