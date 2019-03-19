precision highp float;

#pragma glslify: noise = require(glsl-noise/simplex/2d)
#pragma glslify: map = require(../../lib/map)

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;

  const float repeat = 10.0;
  const vec2 speed = vec2(0.0, 0.1);

  vec2 st = uv;
  st -= u_time * speed;
  st *= repeat;

  const float wiggleRepeat = 2.0;
  const float wiggleSpeed = 0.01;
  const float wiggleAmount = 0.25;
  float wiggle = noise((uv + u_time * wiggleSpeed) * wiggleRepeat);
  wiggle *= uv.y * uv.y; // less wiggly at the bottom
  st.x += wiggle * wiggleAmount;

  float v = map(noise(st), -1.0, 1.0, 0.0, 1.0);
  v -= uv.y;

  vec3 bg = vec3(0.0);
  vec3 fg = mix(vec3(0.0, 0.1, 0.6), vec3(0.1, 0.7, 1.0), uv.y);

  const float edgeWidth = 0.01;
  float alpha = smoothstep(-edgeWidth/2.0, edgeWidth/2.0, v);
  vec3 color = mix(bg, fg, alpha);

  gl_FragColor = vec4(color, 1.0);
}
