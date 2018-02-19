#pragma glslify: noise = require(glsl-noise/simplex/2d)
#pragma glslify: map = require(../lib/map)

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;

  const float repeat = 10.0;
  const vec2 speed = vec2(0.0, 0.05);

  vec2 st = uv;
  st -= u_time * speed;
  st *= repeat;

  float v = map(noise(st), -1.0, 1.0, 0.0, 1.0);
  v -= uv.y;

  vec3 bg = mix(vec3(0.0, 0.1, 0.8), vec3(0.0, 0.2, 0.7), uv.y);
  vec3 fg = vec3(0.9, 0.95, 0.95);

  const float edgeWidth = 0.01;
  float alpha = smoothstep(-edgeWidth/2.0, edgeWidth/2.0, v);
  vec3 color = mix(bg, fg, alpha);

  gl_FragColor = vec4(color, 1.0);
}
