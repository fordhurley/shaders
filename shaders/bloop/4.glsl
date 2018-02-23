#pragma glslify: gradient = require(../../lib/gradient)
#pragma glslify: hash = require(../../lib/hash)
#pragma glslify: impulse = require(../../lib/iq/impulse)
#pragma glslify: map = require(../../lib/map)
#pragma glslify: smoothUnion = require(../../lib/iq/smoothUnion)

float circleSDF(vec2 st, float radius) {
  return length(st) - radius;
}

float randomDotSDF(vec2 st, float t, float seed) {
  float x = hash(seed + 0.293, seed * 2.3 + 1.42);
  float radius = mix(0.04, 0.12, hash(x * 0.45 + seed, seed + PI));

  float startY = 1.0 + 2.0 * radius; // off screen above
  float endY = -2.0 * radius; // off screen below

  // Expand slightly because smoothUnion can oversize things a little:
  startY += 0.1;
  endY -= 0.2;

  float y = mix(startY, endY, t*t*t); // cubic easing

  radius *= mix(1.0, 0.75, t);

  return circleSDF(st - vec2(x, y), radius);
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv.x += 0.5 - aspect/2.0;

  const float magicOffset = 0.0; // to find a nicer beginning
  const float loopTime = 10.0;
  const int numParticles = 12;
  const float bloopiness = 0.22;

  float d = 0.93 - uv.y;
  for (int i = 0; i < numParticles; i++) {
    float shiftedTime = u_time;
    shiftedTime -= loopTime * float(i) / float(numParticles);
    shiftedTime += magicOffset;
    float t = fract(shiftedTime / loopTime);
    float loopIndex = floor(shiftedTime / loopTime);
    float seed = loopIndex + float(i) * 142.8;
    d = smoothUnion(d, randomDotSDF(uv, t, seed), bloopiness);
  }

  float alpha = 1.0 - step(0.0, d);

  vec3 bg = gradient(gl_FragCoord.xy / u_resolution,
    vec3(0.0, 0.4, 0.6),
    vec3(0.0, 0.2, 0.8),
    vec2(0.0, 1.0),
    vec2(0.2, 0.0)
  );
  vec3 fg = vec3(0.9, 0.95, 0.95);
  vec3 color = mix(bg, fg, alpha);

  gl_FragColor = vec4(color, 1.0);
}
