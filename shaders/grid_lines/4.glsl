#pragma glslify: lookAt = require(glsl-look-at)
#pragma glslify: noise = require(glsl-noise/simplex/2d)

#pragma glslify: smoothStepUpDown = require(../../lib/smoothStepUpDown)
#pragma glslify: map = require(../../lib/map)
#pragma glslify: hash = require(../../lib/hash)

#ifndef PI
  #define PI 3.14159
#endif

uniform vec2 u_resolution;
uniform float u_time;

float lines(vec2 uv, float t) {
  const float lensLength = 0.55;

  const vec3 rayOrigin = vec3(0.0, -3.6, 3.4);
  const vec3 rayTarget = vec3(0.0, -1.9, 0.0);

  const float roll = 0.0;
  mat3 cameraMatrix = lookAt(rayOrigin, rayTarget, roll);

  vec3 rayDirection = normalize(cameraMatrix * vec3(uv, lensLength));

  const vec3 planeNormal = vec3(0.0, 0.0, 1.0);
  float distanceToPlane = -dot(rayOrigin, planeNormal) / dot(planeNormal, rayDirection);

  vec2 st = (rayOrigin + rayDirection * distanceToPlane).xy;

  st += noise(st * 0.1 + t * 0.2) * 0.15;
  st += noise(st * 0.4 + t * 0.5) * 0.03;

  vec2 cellID = floor(st);
  vec2 cellUV = fract(st);

  const float lineWidth = 0.06;
  const float lineEdgeWidth = 0.03;

  float alpha = smoothStepUpDown(0.5, lineWidth, lineEdgeWidth, cellUV.x);
  alpha = max(alpha, smoothStepUpDown(0.5, lineWidth, lineEdgeWidth, cellUV.y));

  alpha *= smoothStepUpDown(0.0, 9.0 + lineWidth/2.0, lineEdgeWidth, st.x);
  alpha *= smoothStepUpDown(0.0, 9.0 + lineWidth/2.0, lineEdgeWidth, st.y);
  alpha *= map(distanceToPlane, 4.0, 10.0, 1.0, 0.4);

  return alpha;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  vec2 e = 0.5 / u_resolution;
  float alpha = 0.0;
  // alpha += lines(uv, u_time);
  alpha += lines(uv + vec2( e.x,  e.y), u_time); // ne
  alpha += lines(uv + vec2(-e.x,  e.y), u_time); // nw
  alpha += lines(uv + vec2(-e.x, -e.x), u_time); // sw
  alpha += lines(uv + vec2( e.x, -e.y), u_time); // se
  alpha /= 4.0;

  const vec3 bgColor = vec3(0.0);
  const vec3 lineColor = vec3(1.0);
  vec3 color = mix(bgColor, lineColor, alpha);

  gl_FragColor = vec4(color, 1.0);
}
