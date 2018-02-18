#pragma glslify: noise = require(glsl-noise/simplex/3d)
#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)
#pragma glslify: gain = require(../lib/iq/gain)

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;
  if (aspect < 1.0) {
    uv -= 0.5 - aspect/2.0;
    uv /= aspect;
  }

  const float repeat = 20.0;
  const vec3 speed = vec3(0.0, 0.0, 0.3);

  vec3 st = vec3(uv, 0.0) * repeat;
  st -= u_time * speed;

  float v = noise(st);

  vec3 color;
  color.b = v + 0.4;
  color.b = gain(color.b, 2.0);
  float highlight = cubicPulse(0.5, 0.75, color.b) * 0.5;
  color.r += highlight;
  color.b -= highlight;

  gl_FragColor = vec4(color, 1.0);
}
