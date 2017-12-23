#pragma glslify: map = require('./lib/map')


void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += (1.0 - aspect)/2.0;

  vec3 color = vec3(0.0, 0.0, 0.5);

  float repeat = 40.0;
  uv.x -= uv.y;
  uv *= repeat;
  uv = fract(uv);
  color += step(0.7, uv.x);

  gl_FragColor = vec4(color, 1.0);
}
