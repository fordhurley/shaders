#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');
#pragma glslify: colormap = require('glsl-colormap/portland')

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  gl_FragColor = vec4(uv, 1.0, 1.0);

  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  float theta = atan(uv.y, uv.x) + pi;
  gl_FragColor = vec4(theta / (2.0*pi));

  float numLines = 40.0;
  float lineNumber = floor(theta / (2.0*pi) * numLines);
  gl_FragColor = vec4(lineNumber / numLines);

  float centerTheta = (lineNumber + 0.5) / numLines;
  centerTheta *= 2.0*pi;
  gl_FragColor = vec4(centerTheta / (2.0*pi));

  vec2 lineRay = vec2(cos(centerTheta), sin(centerTheta));
  // Orthogonal projection of uv onto the radial line:
  vec2 pointOnLine = dot(uv, lineRay) * lineRay;
  gl_FragColor = vec4(abs(pointOnLine), 1.0, 1.0);

  vec2 pixUV = gl_FragCoord.xy;
  vec2 pixLine = map(pointOnLine, vec2(-1.0), vec2(1.0), vec2(0.0), u_resolution);
  float pixToLine = distance(pixUV, pixLine);
  gl_FragColor = vec4(pixToLine * 20.0 / u_resolution.x);

  float sliceAngle = theta + 0.5 * (2.0*pi) / numLines;
  float sliceNumber = floor(sliceAngle / (2.0*pi) * numLines);
  sliceNumber /= numLines;
  sliceNumber = fract(sliceNumber);

  vec3 color = colormap(hash(vec2(sliceNumber, 0.4))).rgb;

  float lineWidth = 0.75;
  float edgeWidth = sqrt2;
  float lineMask = smoothstep(
    lineWidth - edgeWidth/2.0,
    lineWidth + edgeWidth/2.0,
    pixToLine
  );
  lineMask = 1.0 - lineMask;
  lineMask *= smoothstep(-0.05, 0.2, length(uv));

  vec3 lineColor = vec3(1.0);
  color = mix(color, lineColor, lineMask);

  gl_FragColor = vec4(color, 1.0);
}
