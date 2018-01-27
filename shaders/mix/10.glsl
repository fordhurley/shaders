#define PI2 6.283185307

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(
    mix(0.3, 0.5, sin(uv.x * PI2)),
    0.0,
    mix(0.4, 0.5, cos(5.0 + uv.y * PI2))
  );
  color = clamp(color, 0.0, 1.0);
  color += 0.2 * (2.0 - uv.x - uv.y);
  gl_FragColor = vec4(color, 1.0);
}
