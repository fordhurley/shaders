precision mediump float;

#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)

#pragma glslify: map = require(../../lib/map)
#pragma glslify: hash = require(../../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

float circle(vec2 uv, vec2 center, float radius) {
  float r = 2.0 * distance(uv, center);
  return 1.0 - step(radius, r);
}

float ring(vec2 uv, vec2 center, float radius) {
  float lineWidth = 8.0 / u_resolution.x;
  float edgeWidth = 5.0 / u_resolution.x;

  float r = 2.0 * distance(uv, center);

  return smoothstep(
    radius - lineWidth - 2.0 * edgeWidth,
    radius - lineWidth - edgeWidth,
    r
  ) - smoothstep(
    radius - edgeWidth,
    radius,
    r
  );
}

vec3 drawCircle(vec3 bg, vec3 color, vec2 uv, vec2 center, float radius) {
  vec3 c = mix(bg, color, circle(uv, center, radius));
  return mix(c, vec3(0.0), ring(uv, center, radius));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  vec3 color = vec3(0.94);

  color = drawCircle(color, vec3(0.973, 0.855, 0.451), uv, vec2(0.0, -0.5), 1.7);
  color = drawCircle(color, vec3(0.992, 0.663, 0.365), uv, vec2(-0.05, -0.15), 1.6);
  color = drawCircle(color, vec3(0.494, 0.722, 0.463), uv, vec2(0.12, -0.3), 1.5);
  color = drawCircle(color, vec3(0.773, 0.596, 0.725), uv, vec2(-0.1, -0.15), 1.2);
  color = drawCircle(color, vec3(0.588, 0.796, 0.78), uv, vec2(0.2, 0.16), 1.14);
  color = drawCircle(color, vec3(0.455, 0.588, 0.745), uv, vec2(-0.07, 0.35), 0.9);
  color = drawCircle(color, vec3(1, 0.714, 0.741), uv, vec2(0.02, 0.55), 0.7);

  gl_FragColor = vec4(color, 1.0);
}
