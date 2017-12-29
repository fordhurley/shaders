// radius at which it reaches 50% black (1 is at a corner):
const float vignetteRadius = 1.2;
const float vignetteSharpness = 1.0;

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  float radius = distance(uv, vec2(0.5));
  radius *= sqrt(2.0); // make it 1 at the corners

  float vignette = 1.0 - radius / vignetteRadius;
  vignette *= vignetteSharpness;
  vignette = clamp(vignette, 0.0, 1.0);
  vignette = smoothstep(0.0, 1.0, vignette);

  gl_FragColor = vec4(vec3(vignette), 1.0);
}
