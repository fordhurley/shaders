#pragma glslify: lookAt = require(glsl-look-at)
#pragma glslify: camera = require(glsl-camera-ray)

#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)
#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)

#ifndef PI
  #define PI 3.14159
#endif

void main() {
  vec2 uv = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.y;

  // float cameraAngle = 0.6;
  vec3 rayOrigin = vec3(0.0, 0.0, 50.0);
  // rayOrigin *= 4.0;
  vec3 rayTarget = vec3(0.0);
  float lensLength = 0.5;

  float roll = u_time * 0.04;
  mat3 cameraMatrix = lookAt(rayOrigin, rayTarget, roll);
  vec3 rayDirection = camera(cameraMatrix, uv, lensLength);

  vec3 planeNormal = vec3(0.0, 0.0, 1.0);
  float distanceToPlane = abs(dot(rayOrigin, planeNormal)) / length(planeNormal);

  vec2 st = (rayOrigin + rayDirection * distanceToPlane).xy;

  const float loopTime = 10.0;
  float t = mod(u_time, loopTime) / loopTime;
  float loopID = floor(u_time / loopTime);

  // float size = map(fract(t), 0.0, 1.0, -1.0, 20.0);
  // size = floor(size);
  // size = max(size, 0.0);
  // size = abs(10.0 - size);

  vec2 cellID = floor(st);
  vec2 cellUV = fract(st);

  float lineWidth = 0.1;

  float lines = cubicPulse(0.5, lineWidth, cellUV.x);
  lines = max(lines, cubicPulse(0.5, lineWidth, cellUV.y));

  float circles = 1.0 - step(0.25, distance(cellUV, vec2(0.5)));

  float fillThreshold = 1.0 - 2.0 * abs(t - 0.5);
  fillThreshold *= 0.7;
  fillThreshold -= 1e-2;
  float layer0 = 1.0 - step(fillThreshold, hash(cellID + mod(loopID, 10.0) * 100.0));
  float layer1 = 1.0 - step(fillThreshold * 0.5, hash(cellID + mod(loopID + 5.0, 10.0) * 100.0));

  // layer0 *= circles;
  // layer1 *= circles;

  float mask = 1.0 - step(40.0, abs(cellID.x));
  mask *= 1.0 - step(40.0, abs(cellID.y));

  // layer0 *= mask;
  // layer1 *= mask;

  vec3 color = vec3(0.0, 0.0, 0.0);

  color = mix(color, vec3(0.0, 0.0, 0.3), layer0);
  color = mix(color, vec3(0.1, 0.3, 0.7), layer1);
  // color *= map(length(st), fillThreshold*50.0, 0.0, 0.5, 1.0);

  gl_FragColor = vec4(color, 1.0);
}
