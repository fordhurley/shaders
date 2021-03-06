#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;

#pragma glslify: map = require(../lib/map)

void main() {
  float lineWidth = 5.0;
  float lineOffset = 35.0; // e.g. node radius
  float arrowHeight = 80.0;
  float arrowWidth = arrowHeight * 1.5;

  vec2 uv = gl_FragCoord.xy; // unnormalized

  float dashGap = (u_mouse.x / u_resolution.x) * 300.0;

  vec2 arrowTip = vec2(
    u_resolution.x / 2.0,
    u_resolution.y - lineOffset
  );
  vec2 arrowBase = arrowTip - vec2(0.0, arrowHeight);

  float xFromCenter = abs(uv.x - arrowTip.x);
  float lineMask = 1.0 - step(lineWidth / 2.0, xFromCenter);
  lineMask -= step(arrowBase.y, uv.y); // line ends at the base of the arrow

  float gapY = mod(uv.y, dashGap);
  lineMask -= step(gapY, dashGap/2.0);
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
