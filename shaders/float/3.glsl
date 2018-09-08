#pragma glslify: map = require('../../lib/map');
#pragma glslify: hash = require('../../lib/hash');
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb');

uniform vec2 u_resolution;
uniform float u_time;

#define pi 3.14159
#define sqrt2 1.41421

float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

float circleMask(vec2 uv, float radius) {
  float d = circleSDF(uv, radius);

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

  float loopTime = 18.0;
  const int numCircles = 40;

  vec3 color = vec3(0.0);

  for (int i = 0; i < numCircles; i++) {
    float shiftedTime = u_time + 50.0;
    shiftedTime -= loopTime * float(i) / float(numCircles);
    float t = fract(shiftedTime / loopTime);
    float loopIndex = floor(shiftedTime / loopTime);

    float seed = float(i) / float(numCircles) + loopIndex * pi;
    seed = fract(seed);

    float radius = map(hash(vec2(seed)), 0.0, 1.0, 0.06, 0.5);

    vec2 center = vec2(0.0);
    center.x = hash(vec2(fract(radius * seed + seed)));
    center.x = map(center.x, 0.0, 1.0, -1.0 - radius * 0.5, 1.0 + radius * 0.5);
    // Move from fully below to fully above (also makes bigger ones move faster):
    center.y = map(t * t * t, 0.0, 1.0, -1.0 - radius, 1.0 + radius);

    float hue = hash(vec2(fract(radius * seed + pi)));
    vec3 circleColor = hsv2rgb(vec3(hue, 0.92, 0.6));
    float mask = circleMask(uv - center, radius);
    color += circleColor * mask;
  }

  gl_FragColor = vec4(color, 1.0);
}
