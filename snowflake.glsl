#define PI 3.14159

#pragma glslify: hash = require(./lib/hash)
#pragma glslify: noise = require(glsl-noise/simplex/2d)

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv = uv * 2.0 - 1.0;

  float radius = length(uv);
  float theta = atan(uv.y, uv.x);
  theta /= 2.0 * PI;

  // "Fold" the space, like folding up the paper:
  float radialRepeat = 3.0;
  float angularRepeat = 6.0;
  vec2 st = vec2(
    fract(radius * radialRepeat),
    fract(theta * angularRepeat)
  );
  // More symmetry:
  st = 2.0 * abs(st - 0.5);

  vec3 bgColor = vec3(0.0, 0.0, 0.2);
  vec3 fgColor = bgColor + 0.5;

  vec2 cell = floor(st * vec2(10.0, 15.0));
  float cellValue = hash(cell).y;

  float snowflake = 0.0;
  snowflake += step(0.75, cellValue);

  // Mask to circle:
  snowflake *= 1.0 - step(1.0, radius);
  snowflake = clamp(snowflake, 0.0, 1.0);

  vec3 color = mix(bgColor, fgColor, snowflake);

  gl_FragColor = vec4(color, 1.0);
}
