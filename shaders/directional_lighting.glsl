precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform sampler2D normalMap; // ../textures/brickwall_normal-map.jpg

const float lightIntensity = 0.35;
const float ambientIntensity = 0.45;

// Move mouse to change light direction.

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  vec3 color = vec3(0.7, 0.1, 0.1);

  vec3 normal = texture2D(normalMap, uv).xyz;
  normal = 2.0 * normal - 1.0; // map to [-1, 1] range

  vec2 mouse = 2.0 * u_mouse / u_resolution - 1.0; // map to [-1, 1] range
  vec3 lightDirection = vec3(mouse, 1.0); // where it's coming from

  float light = dot(normal, lightDirection * lightIntensity);
  light += ambientIntensity;
  color *= light;
  color = clamp(color, 0.0, 1.0);

  gl_FragColor = vec4(color, 1.0);
}
