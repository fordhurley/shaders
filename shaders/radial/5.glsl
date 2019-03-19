precision mediump float;

#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');
#pragma glslify: colormap = require('glsl-colormap/warm');

uniform vec2 u_resolution;
uniform float u_time;

#define pi 3.14159
#define sqrt2 1.41421

float lineMask(vec2 uv, float theta) {
  vec2 lineRay = vec2(cos(theta), sin(theta));
  // Orthogonal projection of uv onto the radial line:
  vec2 pointOnLine = dot(uv, lineRay) * lineRay;

  vec2 pixUV = gl_FragCoord.xy;
  vec2 pixLine = map(pointOnLine, vec2(-1.0), vec2(1.0), vec2(0.0), u_resolution);
  float pixToLine = distance(pixUV, pixLine);

  float lineWidth = 0.5;
  float edgeWidth = 8.0;
  float mask = smoothstep(
    lineWidth - edgeWidth/2.0,
    lineWidth + edgeWidth/2.0,
    pixToLine
  );
  mask = 1.0 - mask;

  return mask;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  gl_FragColor = vec4(uv, 1.0, 1.0);
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  float loopTime = 10.0;

  vec3 color = vec3(0.075);

  const int numLines = 50;
  for (int i = 0; i < numLines; i++) {
    float shiftedTime = u_time;
    shiftedTime -= loopTime * float(i) / float(numLines);
    float t = fract(shiftedTime / loopTime);
    float loopIndex = floor(shiftedTime / loopTime);

    float seed = float(i) / float(numLines) + loopIndex;
    seed = fract(seed);
    vec3 lineColor = colormap(hash(vec2(seed))).rgb;

    float theta = hash(vec2(seed)) * 2.0 * pi;

    float mask = lineMask(uv, theta);
    mask *= smoothstep(0.0, 0.1, t) - smoothstep(0.9, 1.0, t);
    color = mix(color, lineColor, mask);
  }

  gl_FragColor = vec4(color, 1.0);
}
