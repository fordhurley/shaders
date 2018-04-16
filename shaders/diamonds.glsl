uniform vec2 u_resolution;
uniform float u_time;

#define sqrt2over2 0.707107

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  uv *= 2.0;
  uv -= 1.0;
  uv = abs(2.0 * fract(uv + 0.5) - 1.0);

  const float loopTime = 5.0;
  float t = mod(u_time, loopTime) / loopTime;
  uv *= t * 20.0;

  float line = dot(uv, vec2(sqrt2over2));
  line = fract(line);

  float width = 0.5 - 0.5 * smoothstep(0.5, 1.0, t);
  line = step(1.0 - width, line);

  line *= 1.0 - smoothstep(0.9, 1.0, t);

  vec3 color = vec3(line);

  gl_FragColor = vec4(color, 1.0);
}
