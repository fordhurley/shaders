#pragma glslify: map = require(./lib/map)
#pragma glslify: noise = require(./lib/valueNoise)

float clamp01(float x) {
  return clamp(x, 0.0, 1.0);
}

// https://thebookofshaders.com/13/

float fbm(vec2 st) {
  float value = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rotation = mat2(
    cos(0.5), sin(0.5),
    -sin(0.5), cos(0.5)
  );
  for (int i = 0; i < 5; i++) {
    value += amplitude * map(noise(st), -1.0, 1.0, 0.0, 1.0);
    st = rotation * st;
    st *= 2.0;
    st += shift;
    amplitude *= 0.5;
  }
  return value;
}

vec4 cloud(vec2 st, float t) {
  vec2 q = vec2(0.0);
  q.x = fbm(st);
  q.y = fbm(st + 1.0);

  vec2 r = vec2(0.0);
  r.x = fbm(st + q + vec2(1.7, 9.2) + 0.15 * t);
  r.y = fbm(st + q + vec2(8.3, 2.8) + 0.13 * t);

  float f = fbm(st + r);

  vec3 color1 = vec3(0.5);
  vec3 color2 = vec3(0.8);
  vec3 color3 = vec3(1.0);

  vec3 color = mix(color1, color2, clamp01(length(q)));
  color = mix(color, color3, clamp01(r.x));

  float alpha = 1.0 - clamp01(f * f * 3.0);

  return vec4(color, alpha);
}

// http://iquilezles.org/www/articles/functions/functions.htm
float gain(float x, float k) {
  float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
  return (x<0.5)?a:1.0-a;
}

vec3 skyGradient(vec2 uv) {
  vec3 bg = vec3(0.012, 0.6, 0.741);
  vec3 fg = vec3(0.314, 0.686, 0.894);

  float k = uv.y;
  k *= map(noise(uv), -1.0, 1.0, 0.0, 1.5);
  return mix(bg, fg, clamp01(k));
}

float cloudShapes(vec2 st) {
  float alpha = fbm(st);
  alpha = map(alpha, 0.0, 1.0, -0.5, 1.3);
  alpha = gain(alpha, 10.0);
  return clamp01(alpha);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time;

  vec3 color = skyGradient(uv);

  vec2 repeat = vec2(2.0, 10.0);
  vec2 offset = vec2(22.5);
  uv = uv * repeat + offset;

  float scrollSpeed = 0.05;
  uv.x += t * scrollSpeed;

  float warpSpeed = 1.25;
  vec4 cloudColor = cloud(uv, t * warpSpeed);

  float alpha = cloudColor.a;
  alpha *= cloudShapes(uv);
  color = mix(color, cloudColor.rgb, alpha);

  gl_FragColor = vec4(color, 1.0);
}
