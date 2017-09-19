uniform sampler2D noiseTex; // textures/noise.png
vec2 texSize = vec2(512.0);
float raininess = 0.4;

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec3 color = vec3(0.463, 0.463, 0.549);

  float t = iGlobalTime * 0.4;

  uv.x *= 100.0;
  uv.y *= 4.0;

  // Move rain down by moving uv up:
  uv.y += t * 50.0;

  vec2 iUV = floor(uv);
  vec2 fUV = uv - iUV;

  float noise = texture2D(noiseTex, fract(iUV / texSize)).r;
  noise = step(raininess, noise);

  float rainWidth = 0.5;
  vec3 rainColor = vec3(0.1);
  float rain = 1.0 - noise;
  rain *= step(0.5 - rainWidth/2.0, fUV.x) - step(0.5 + rainWidth/2.0, fUV.x);
  color = mix(color, rainColor, rain);

  gl_FragColor = vec4(color, 1.0);
}
