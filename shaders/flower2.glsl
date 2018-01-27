#define PI 3.14159

#pragma glslify: map = require(../lib/map)

// "Fold" up a space, like folding up paper for a snowflake.
float fold(float x, float times) {
  x = fract(x * times);
  // Symmetry:
  x = 2.0 * abs(x - 0.5);
  return x;
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv = uv * 2.0 - 1.0;

  // Normalized polar coordinates:
  float radius = length(uv);
  float theta = atan(uv.y, uv.x);
  theta /= 2.0 * PI;
  theta += 0.5;

  vec3 color = vec3(0.9, 0.9, 1.0);

  float width = map(radius, 0.0, 1.0, 3.0, 0.0);
  vec4 petals = vec4(0.2, 0.4, 0.8, 1.0);
  petals.a = 1.0 - step(width/2.0, fold(theta - u_time * 0.005, 18.0));
  color = mix(color, petals.rgb, petals.a);

  width = map(radius, 0.0, 0.9, 2.0, 0.0);
  width = sqrt(width);
  width += 0.3 * (0.9 - radius);
  width *= 1.0 - step(0.9, radius);
  petals = vec4(0.0, 0.2, 0.5, 1.0);
  petals.a = 1.0 - step(width/2.0, fold(theta + u_time * 0.005, 6.0));
  color = mix(color, petals.rgb, petals.a);

  width = map(radius, 0.0, 0.5, 3.0, 0.0);
  width = sqrt(width);
  width *= 1.0 - step(0.5, radius);
  petals = vec4(0.6, 0.2, 0.7, 1.0);
  petals.a = 1.0 - step(width/2.0, fold(theta - u_time * 0.025, 12.0));
  color = mix(color, petals.rgb, petals.a);

  width = map(radius, 0.0, 0.15, 2.0, 0.0);
  width = sqrt(width);
  width *= 1.0 - step(0.15, radius);
  petals = vec4(0.5, 0.6, 0.9, 0.0);
  petals.a = 1.0 - step(width/2.0, fold(theta + u_time * 0.04, 24.0));
  color = mix(color, petals.rgb, petals.a);

  gl_FragColor = vec4(color, 1.0);
}
