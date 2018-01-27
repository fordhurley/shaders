#define PI 3.14159

#pragma glslify: map = require(../lib/map)

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv = uv * 2.0 - 1.0;

  float radius = length(uv);
  float theta = atan(uv.y, uv.x);
  theta /= 2.0 * PI;
  theta += 0.5;
  // gl_FragColor = vec4(theta); return;

  // "Fold" the space, like folding up the paper:
  float radialRepeat = 4.0;
  float angularRepeat = 6.0;
  vec2 st = vec2(
    fract(radius * radialRepeat),
    fract(theta * angularRepeat)
  );
  // More symmetry:
  st = 2.0 * abs(st - 0.5);
  // gl_FragColor = vec4(st.x, 0.0, st.y, 1.0); return;

  vec3 bgColor = vec3(0.0, 0.0, 0.2);
  vec3 fgColor = vec3(
    abs(floor(radius * radialRepeat) / radialRepeat - 0.5) + 0.25,
    0.2,
    0.5
  );

  float flower = step(st.x, st.y);

  // Mask to circle:
  flower *= 1.0 - step(1.0, radius);
  flower = clamp(flower, 0.0, 1.0);

  vec3 color = mix(bgColor, fgColor, flower);

  gl_FragColor = vec4(color, 1.0);
}
