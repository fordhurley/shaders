float distanceSq(vec2 a, vec2 b) {
  vec2 d = a - b;
  return dot(d, d);
}

void main() {
  vec2 uv = gl_FragCoord.xy;
  vec2 mouse = iMouse * iResolution;
  const float radius = 20.0;

  gl_FragColor = vec4(1.0);
  if (distanceSq(uv, mouse) < radius * radius) {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  }
}
