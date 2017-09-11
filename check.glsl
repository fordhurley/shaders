uniform sampler2D noiseTex; // textures/noise.png

vec3 noise(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec3 color = vec3(0.0, 0.28, 0.62);

  float repeat = 16.0;
  vec2 grid = floor(uv * repeat);
  float check = mod(grid.x + grid.y, 2.0); // 0 or 1
  color *= check;

  color += 0.1 * noise(uv).x;

  gl_FragColor = vec4(color, 1.0);
}
