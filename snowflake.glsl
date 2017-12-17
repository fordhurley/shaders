#define PI 3.14159

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 st = uv * 2.0 - 1.0;

  float radius = length(st);

  float radialRepeat = 3.0;
  radius = fract(radius * radialRepeat);

  float theta = atan(st.y, st.x);
  theta /= 2.0 * PI;

  float angularRepeat = 6.0;
  theta = fract(theta * angularRepeat);

  vec3 color = vec3(radius, 0.0, theta);

  gl_FragColor = vec4(color, 1.0);
}
