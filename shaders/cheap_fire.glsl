#pragma glslify: noise = require(glsl-noise/simplex/2d)
#pragma glslify: map = require(../lib/map)
#pragma glslify: smoothStepUpDown = require(../lib/smoothStepUpDown)

uniform vec2 u_resolution;
uniform float u_time;

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rotation = mat2(
    cos(0.5), sin(0.5),
    -sin(0.5), cos(0.5)
  );
  for (int i = 0; i < 2; i++) {
    value += amplitude * map(noise(p), -1.0, 1.0, 0.0, 1.0);
    p = rotation * p;
    p *= 2.0;
    p += shift;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;
  if (aspect < 1.0) {
    uv -= 0.5 - aspect/2.0;
    uv /= aspect;
  }
  uv.x = map(uv.x, 0.0, 1.0, -1.0, 1.0);
  uv.y = map(uv.y, 0.0, 1.0, 0.0, 1.0);

  const float repeat = 20.0;
  const float speed = 10.0;

  vec2 st = uv * repeat;
  st.y -= u_time * speed;

  vec3 color;
  color.r = fbm(st);
  color.g = color.r * map(uv.y, -0.2, 0.2, 3.0, 0.0);

  vec2 shapeUV = uv;
  shapeUV.x *= map(uv.y, 0.0, 0.5, 1.0, 5.0); // get narrower as we go up
  color *= smoothStepUpDown(0.0, 0.25, 0.15, shapeUV.x);
  color *= smoothstep(-0.1, 0.01, shapeUV.y) - smoothstep(0.1, 0.5, shapeUV.y);

  gl_FragColor = vec4(color, 1.0);
}
