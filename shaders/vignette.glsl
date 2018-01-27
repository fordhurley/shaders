// radius at which it reaches 50% black (1 is at a corner):
const float vignetteRadius = 1.2;
const float vignetteSharpness = 1.0;

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  float radius = distance(uv, vec2(0.5));
  radius *= sqrt(2.0); // make it 1 at the corners

  float vignette = 1.0 - radius / vignetteRadius;
  vignette *= vignetteSharpness;
  vignette = clamp(vignette, 0.0, 1.0);
  vignette = smoothstep(0.0, 1.0, vignette);

  gl_FragColor = vec4(vec3(vignette), 1.0);
}
