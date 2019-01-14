#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

#pragma glslify: map = require(../lib/map)

void main() {
  // Our pretend "uniforms" (uniform within each quad)
  vec2 size = u_resolution;
  float lineWidth = 5.0;
  float lineOffset = 35.0; // e.g. node radius
  float arrowHeight = 80.0;
  float arrowWidth = arrowHeight * 1.5;

  // Our pretend varyings:
  vec2 uv = gl_FragCoord.xy; // unnormalized
  vec2 st = uv / size; // normalized [0, 1]

  vec2 arrowTip = vec2(
    size.x / 2.0,
    size.y - lineOffset
  );
  vec2 arrowBase = arrowTip - vec2(0.0, arrowHeight);

  float xFromCenter = abs(uv.x - arrowTip.x);
  float lineMask = 1.0 - step(lineWidth / 2.0, xFromCenter);
  lineMask -= step(arrowBase.y, uv.y); // line ends at the base of the arrow
  lineMask = clamp(lineMask, 0.0, 1.0);

  float arrowMask = step(arrowBase.y, uv.y); // base of the arrow
  arrowMask -= step(arrowTip.y, uv.y); // tip of the arrow
  float diagonalEdgeX = map(
    uv.y,
    arrowBase.y, arrowTip.y,
    arrowWidth / 2.0, 0.0
  );
  arrowMask -= step(diagonalEdgeX, xFromCenter);

  float mask = lineMask + arrowMask;

	gl_FragColor = vec4(mask, mask, mask, 1.0);
}
