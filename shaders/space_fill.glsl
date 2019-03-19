precision highp float;

#pragma glslify: lookAt = require(glsl-look-at)

#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)

#ifndef PI
  #define PI 3.14159
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  vec3 rayOrigin = vec3(0.0, 0.0, 50.0);
  vec3 rayTarget = vec3(0.0);
  float lensLength = 0.5;

  float roll = u_time * 0.04;
  mat3 cameraMatrix = lookAt(rayOrigin, rayTarget, roll);
  vec3 rayDirection = normalize(cameraMatrix * vec3(uv, lensLength));

  vec3 planeNormal = vec3(0.0, 0.0, 1.0);
  float distanceToPlane = abs(dot(rayOrigin, planeNormal)) / length(planeNormal);

  vec2 st = (rayOrigin + rayDirection * distanceToPlane).xy;

  const float loopTime = 10.0;
  float t = mod(u_time, loopTime) / loopTime;
  float loopID = floor(u_time / loopTime);

  vec2 cellID = floor(st);

  float fillThreshold = 1.0 - 2.0 * abs(t - 0.5);
  fillThreshold = map(fillThreshold, 0.0, 1.0, -0.01, 0.7);

  float layer0 = 1.0 - step(fillThreshold, hash(cellID + mod(loopID, 10.0) * 100.0));
  float layer1 = 1.0 - step(fillThreshold * 0.5, hash(cellID + mod(loopID + 5.0, 10.0) * 100.0));

  vec3 color = vec3(0.0, 0.0, 0.0);

  color = mix(color, vec3(0.0, 0.0, 0.3), layer0);
  color = mix(color, vec3(0.1, 0.3, 0.7), layer1);

  gl_FragColor = vec4(color, 1.0);
}
