precision mediump float;

uniform float u_time;

#define sqrt2over2 0.707107

const float scale = 100.0;

float circle(vec2 st) {
  float r = length(st);
  const float radius = 0.2;
  return 1.0 - step(radius, r);
}

void main() {
  vec2 uv = gl_FragCoord.xy;
  uv /= scale;

  vec2 cellNum = floor(uv);

  const float speed = 0.5;
  float direction = sign(mod(cellNum.y, 2.0) - 0.5);

  uv.x += u_time * speed * direction;
  vec2 cellUV = fract(uv);

  vec3 color = vec3(cellUV.x, 0.0, cellUV.y);
  color *= 0.0;

  color = mix(color, vec3(1.0), circle(cellUV - 0.5));

  gl_FragColor = vec4(color, 1.0);
}
