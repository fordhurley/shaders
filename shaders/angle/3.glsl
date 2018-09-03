uniform vec2 u_resolution;
uniform float u_time;

#define sqrt2over2 0.707107

// #define DEBUG

#ifdef DEBUG
float dot(vec2 st, float radius) {
  float r = length(st);
  return 1.0 - step(radius, r);
}
#endif

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  vec2 st = uv;
  st *= 2.0;
  st -= 1.0;
  st = abs(2.0 * fract(st + 0.5) - 1.0);

  const float loopTime = 10.0;
  float t = mod(u_time, loopTime) / loopTime;
  float zoom = t;
  zoom = abs(2.0 * zoom - 1.0);
  zoom *= zoom;
  zoom = 1.0 - zoom;
  st *= zoom * 15.0;

  float line = dot(st, vec2(sqrt2over2));
  line = fract(line);

  float width = min(0.8, zoom);
  line = step(1.0 - width, line);

  vec3 color = vec3(line);

  #ifdef DEBUG
  const float dotRadius = 0.01;
  const vec3 dotColor = vec3(0.9, 0.0, 0.0);
  color = mix(color, dotColor, dot(uv - vec2(dotRadius, zoom), dotRadius));
  color = mix(color, dotColor, dot(uv - vec2(dotRadius + 2.0*dotRadius, width), dotRadius));
  #endif

  gl_FragColor = vec4(color, 1.0);
}
