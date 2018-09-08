#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');

uniform vec2 u_resolution;
uniform float u_time;

#define pi 3.14159
#define sqrt2 1.41421

vec3 sliceColor(vec2 uv) {
  const float numLines = 40.0;
  float theta = atan(uv.y, uv.x) + pi;
  float sliceAngle = theta + 0.5 * (2.0*pi) / numLines;
  float sliceNumber = floor(sliceAngle / (2.0*pi) * numLines);
  sliceNumber /= numLines;
  sliceNumber = fract(sliceNumber);
  float gray = hash(vec2(sliceNumber, 0.4));
  return vec3(gray);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  vec2 e = 0.5 / u_resolution;

  // Antialiasing by averaging neighbor pixels (MSAA):
  vec3 color;
  color += 0.25 * sliceColor(uv + vec2(0.0, e.y)); // n
  color += 0.25 * sliceColor(uv + vec2(e.x, 0.0)); // e
  color += 0.25 * sliceColor(uv + vec2(0.0, -e.y)); // s
  color += 0.25 * sliceColor(uv + vec2(-e.x, 0.0)); // w

  gl_FragColor = vec4(color, 1.0);
}
