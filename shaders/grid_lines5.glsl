#pragma glslify: lookAt = require(glsl-look-at)
#pragma glslify: camera = require(glsl-camera-ray)
#pragma glslify: noise = require(glsl-noise/simplex/2d)

#pragma glslify: smoothStepUpDown = require(../lib/smoothStepUpDown)
#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)

#ifndef PI
  #define PI 3.14159
#endif

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  vec3 rayOrigin = vec3(0.0, -3.6, 3.4);
  vec3 rayTarget = vec3(0.0, -1.9, 0.0);
  float lensLength = 0.55;

  float roll = 0.0;
  mat3 cameraMatrix = lookAt(rayOrigin, rayTarget, roll);
  vec3 rayDirection = camera(cameraMatrix, uv, lensLength);

  vec3 planeNormal = vec3(0.0, 0.0, 1.0);
  float distanceToPlane = -dot(rayOrigin, planeNormal) / dot(planeNormal, rayDirection);

  vec2 st = (rayOrigin + rayDirection * distanceToPlane).xy;

  float t = u_time;
  st += noise(st * 0.1 + t * 0.2) * 0.1;
  st += noise(st * 0.4 + t * 0.5) * 0.025;

  vec2 cellID = floor(st);
  vec2 cellUV = fract(st);

  float lineWidth = 0.06;
  float lineEdgeWidth = 0.03;

  float lines = smoothStepUpDown(0.5, lineWidth, lineEdgeWidth, cellUV.x);
  lines = max(lines, smoothStepUpDown(0.5, lineWidth, lineEdgeWidth, cellUV.y));

  lines *= smoothStepUpDown(0.0, 9.0 + lineWidth, lineEdgeWidth, st.x);
  lines *= smoothStepUpDown(0.0, 9.0 + lineWidth, lineEdgeWidth, st.y);


  vec3 color = vec3(0.0);
  color = mix(color, vec3(1.0), lines);

  // color.r -= lines * map(distanceToPlane, 4.0, 10.0, 0.0, 0.4);
  // color.g -= lines * map(distanceToPlane, 4.0, 10.0, 0.0, 0.4);

  gl_FragColor = vec4(color, 1.0);
}
