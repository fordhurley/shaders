// (0, 0, 1) - (1, 0, 1)
//  |                 |
//  |                 |
//  |                 |
// (1, 1, 1) - (1, 0, 0)

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec3 color;
  color.r += uv.x * (1.0 - uv.y);
  color.r += uv.x * uv.y;
  color.r += (1.0 - uv.x) * (1.0 - uv.y);
  color.g += (1.0 - uv.x) * (1.0 - uv.y);
  color.b += uv.x * uv.y;
  color.b += (1.0 - uv.x) * uv.y;
  color.b += (1.0 - uv.x) * (1.0 - uv.y);
  gl_FragColor = vec4(color, 1.0);
}
