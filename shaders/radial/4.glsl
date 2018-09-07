#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  float numLines = 40.0;

  float theta = atan(uv.y, uv.x) + pi;
  float sliceAngle = theta + 0.5 * (2.0*pi) / numLines;
  float sliceNumber = floor(sliceAngle / (2.0*pi) * numLines);
  sliceNumber /= numLines;
  sliceNumber = fract(sliceNumber);

  vec3 color = vec3(hash(vec2(sliceNumber, 0.4)));
  gl_FragColor = vec4(color, 1.0);
}
