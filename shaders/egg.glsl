precision mediump float;

#pragma glslify: smoothUnion = require(../lib/iq/smoothUnion)

float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;

  float d = smoothUnion(
    circleSDF(uv - vec2(0.5, 0.42), 0.25),
    circleSDF(uv - vec2(0.5, 0.72), 0.05),
    0.45
  );

  float alpha = 1.0 - step(0.0, d);

  vec3 bg = vec3(0.678, 0.831, 0.992);
  vec3 fg = vec3(0.945, 0.918, 0.843);
  vec3 color = mix(bg, fg, alpha);

  gl_FragColor = vec4(color, 1.0);
}
