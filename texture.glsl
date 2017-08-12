uniform sampler2D texture;

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;

  uv.x *= aspect;

  gl_FragColor = texture2D(texture, uv);
  // gl_FragColor = vec4(1.0);
}
