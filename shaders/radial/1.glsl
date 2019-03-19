precision mediump float;

#pragma glslify: map = require('../../lib/map');

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
  gl_FragColor = vec4(abs(pointOnLine), 0.0, 1.0);

  float distanceToLine = distance(uv, pointOnLine);
  gl_FragColor = vec4(distanceToLine);

  vec2 pixUV = gl_FragCoord.xy;
  vec2 pixLine = map(pointOnLine, vec2(-1.0), vec2(1.0), vec2(0.0), u_resolution);
  float pixToLine = distance(pixUV, pixLine);
  gl_FragColor = vec4(pixToLine * 20.0 / u_resolution.x);

  float lineWidth = 1.0;
  float edgeWidth = sqrt2;
  float line = 1.0 - smoothstep(
    lineWidth - edgeWidth/2.0,
    lineWidth + edgeWidth/2.0,
    pixToLine
  );

  vec3 color = vec3(1.0);
  color = mix(color, vec3(0.0), line);

  float circleRadius = 0.3;
  edgeWidth /= u_resolution.x;
  float radius = length(uv);
  float circle = smoothstep(
    circleRadius - edgeWidth/2.0,
    circleRadius + edgeWidth/2.0,
    radius
  );
  color *= circle;

  gl_FragColor = vec4(color, 1.0);
}
