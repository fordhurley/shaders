precision mediump float;

#pragma glslify: gradient = require(../lib/gradient)

uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  const vec3 startColor = vec3(1.0, 0.0, 0.0);
  const vec3 endColor = vec3(0.0, 0.0, 1.0);
  vec2 startUV = u_mouse / u_resolution;
  const vec2 endUV = vec2(1.0, 1.0);

  vec3 color = gradient(uv, startColor, endColor, startUV, endUV);

  gl_FragColor = vec4(color, 1.0);
}
