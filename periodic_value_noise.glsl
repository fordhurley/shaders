#pragma glslify: map = require('./lib/map')
#pragma glslify: valueNoise = require(./lib/valueNoise)

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  uv *= 8.0;

  float noise = valueNoise(uv, vec2(8.0));
  // noise = valueNoise(uv);
  noise = map(noise, -1.0, 1.0, 0.0, 1.0);

  vec3 color = vec3(noise);

  gl_FragColor = vec4(color, 1.0);
}
