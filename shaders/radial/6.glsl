#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');
#pragma glslify: colormap = require('glsl-colormap/hot');

uniform vec2 u_resolution;
uniform float u_time;

#define pi 3.14159
#define sqrt2 1.41421

float rect(vec2 st, vec2 size) {
  vec2 d = abs(st) - size/2.0;
  // d is negative on the inside, so take the more positive, which is the
  // distance to the closest edge:
  float inside = max(d.x, d.y);
  // d is positive outside, so the max(d, 0) zeros any components that are
  // inside, e.g. when vertically above the box we only care about the y
  // distance. When we're fully outside (diagonally) the box, this is the
  // length from the nearest corner.
  float outside = length(max(d, 0.0));
  return min(inside, 0.0) + outside;
}

float lineMask(vec2 uv, float theta, vec2 size) {
  mat2 rotation = mat2(
    cos(theta), sin(theta),
    -sin(theta), cos(theta)
  );
  uv = rotation * uv;
  float d = rect(uv, size);

  float edgeWidth = sqrt2 / u_resolution.x;
  float mask = 1.0 - smoothstep(
    -edgeWidth/2.0,
    edgeWidth/2.0,
    d
  );

  return mask;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  gl_FragColor = vec4(uv, 1.0, 1.0);
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  float loopTime = 12.0;
  vec2 lineSize = vec2(4.0 / u_resolution.x, 2.0);
  const int numLines = 40;

  vec3 color = vec3(0.0);

  for (int i = 0; i < numLines; i++) {
    float shiftedTime = u_time;
    shiftedTime -= loopTime * float(i) / float(numLines);
    float t = fract(shiftedTime / loopTime);
    float loopIndex = floor(shiftedTime / loopTime);

    float seed = float(i) / float(numLines) + loopIndex * pi;
    seed = fract(seed);
    float angle = hash(vec2(seed));

    vec3 lineColor = colormap(t).rgb;

    vec2 center = vec2(0.0);
    center.x = hash(vec2(fract(angle * seed + seed)));
    center.x = map(center.x, 0.0, 1.0, -1.0, 1.0);
    // Move from fully below to fully above:
    center.y = map(t * t, 0.0, 1.0, -lineSize.y, lineSize.y);
    float mask = lineMask(uv - center, angle * 2.0 * pi, lineSize);
    color = mix(color, lineColor, mask);
  }

  gl_FragColor = vec4(color, 1.0);
}
