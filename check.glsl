uniform sampler2D noiseTex; // textures/noise.png

vec3 noise(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  float t = iGlobalTime;
  uv += 0.25 * vec2(cos(t * 0.1), sin(t * 0.2));

  vec3 color = vec3(0.0, 0.28, 0.62);

  float repeat = 15.0;
  vec2 grid = floor(uv * repeat);
  float verticalStipes = mod(grid.x, 2.0); // 0 or 1
  float horizontalStripes = mod(grid.y, 2.0); // 0 or 1
  color *= verticalStipes + 0.5 * horizontalStripes;

  color += 0.1 * noise(uv).x;

  gl_FragColor = vec4(color, 1.0);
}
