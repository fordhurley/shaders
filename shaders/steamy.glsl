#pragma glslify: map = require(../lib/map)
#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)
#pragma glslify: gain = require(../lib/iq/gain)
#pragma glslify: noise = require(glsl-noise/classic/2d)


float clamp01(float x) {
  return clamp(x, 0.0, 1.0);
}

vec3 clamp01(vec3 v) {
  return clamp(v, 0.0, 1.0);
}

// https://thebookofshaders.com/13/

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rotation = mat2(
    cos(0.5), sin(0.5),
    -sin(0.5), cos(0.5)
  );
  for (int i = 0; i < 4; i++) {
    value += amplitude * map(noise(p), -1.0, 1.0, 0.0, 1.0);
    p = rotation * p;
    p *= 2.0;
    p += shift;
    amplitude *= 0.5;
  }
  return value;
}

vec4 cloud(vec2 p, float t) {
  vec2 q = vec2(0.0);
  q.x = fbm(p);
  q.y = fbm(p + 1.0);

  vec2 r = vec2(0.0);
  r.x = fbm(p + q + vec2(1.7, 9.2) - 0.05 * t);
  r.y = fbm(p + q + vec2(8.3, 2.8) + 0.03 * t);

  float f = fbm(p + r);

  vec3 color = vec3(0.8, 0.2, 0.2);
  color = mix(color, vec3(0.4, 0.4, 0.8), clamp01(length(q)));
  color = mix(color, vec3(1.0), clamp01(1.5 * r.x));
  color = clamp01(color);

  float alpha = f*f*f + 0.6*f*f + 0.5*f;

  return vec4(color, alpha);
}

vec3 gradient(vec2 uv) {
  const vec3 startColor = vec3(0.969, 0.067, 0.063);
  const vec3 endColor = vec3(0.443, 0, 0.588);
  const vec2 startUV = vec2(0.0, 1.0);
  const vec2 endUV = vec2(1.0, 0.0);

  vec2 gradientVector = endUV - startUV;
  float k = dot(uv - startUV, gradientVector);
  k /= dot(gradientVector, gradientVector); // length squared
  k = clamp(k, 0.0, 1.0);
  return mix(startColor, endColor, k);
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  const float loopTime = 8.0;
  float t = mod(u_time, loopTime) / loopTime;

  vec3 color = gradient(uv);

  vec2 repeat = vec2(4.0);
  repeat.x *= u_resolution.x / u_resolution.y;
  vec2 offset = vec2(0.0);

  vec2 steamVelocity = vec2(4.0, 2.5);
  offset -= t * steamVelocity;

  vec2 steamUV = uv * repeat + offset;

  float warpSpeed = 25.0;
  vec4 steamColor = cloud(steamUV, t * warpSpeed);

  const float steaminess = 0.5;
  float steamWidth = 2.0;
  float steamCenter = map(t, 0.0, 1.0, -steamWidth/2.0, 1.0 + steamWidth/2.0); // making sure that no steam is visible at the loop "seam"
  float steamFade = cubicPulse(steamCenter, steamWidth, uv.x);
  steamFade *= steaminess;
  steamColor.a *= steamFade;

  color = mix(color, steamColor.rgb, steamColor.a);

  gl_FragColor = vec4(color, 1.0);
}
