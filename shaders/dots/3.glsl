precision mediump float;
precision mediump int;

#pragma glslify: map = require(../../lib/map)
#pragma glslify: hash = require(../../lib/hash)

uniform vec2 u_resolution;

#define pi 3.14159
#define sqrt2 1.41421

vec3 colorTheme(float x) {
  const float numColors = 7.0;
  x = mod(x * numColors, numColors);
  if (x < 1.0) {
    return vec3(1, 0.714, 0.741);
  }
  if (x < 2.0) {
    return vec3(0.455, 0.588, 0.745);
  }
  if (x < 3.0) {
    return vec3(0.588, 0.796, 0.78);
  }
  if (x < 4.0) {
    return vec3(0.773, 0.596, 0.725);
  }
  if (x < 5.0) {
    return vec3(0.494, 0.722, 0.463);
  }
  if (x < 6.0) {
    return vec3(0.992, 0.663, 0.365);
  }
  return vec3(0.973, 0.855, 0.451);
}

float circle(vec2 uv, vec2 center, float radius) {
  float r = 2.0 * distance(uv, center);
  return 1.0 - step(radius, r);
}

float ring(vec2 uv, vec2 center, float radius) {
  float lineWidth = 40.0 / u_resolution.x;
  float edgeWidth = 40.0 / u_resolution.x;

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

vec3 voronoiCircles(vec3 bg, vec2 uv, vec2 repeat) {
  vec2 cellNum = floor(uv * repeat);
  vec2 cellUV = fract(uv * repeat);

  vec2 center = vec2(
    hash(cellNum),
    hash(cellNum + 32.134)
  );
  float distToEdge = min(center.x, center.y);
  distToEdge = min(distToEdge, 1.0 - center.x);
  distToEdge = min(distToEdge, 1.0 - center.y);
  float radius = distToEdge * 1.2;
  vec3 color = colorTheme(hash(cellNum + 1928.2099));

  return drawCircle(bg, color, cellUV, center, radius);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;


  vec3 color = vec3(0.94);
  color = voronoiCircles(color, uv, vec2(20.0));

  gl_FragColor = vec4(color, 1.0);
}
