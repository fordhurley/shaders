void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(
    mix(0.0, 0.8, uv.x),
    mix(0.2, 0.6, uv.y),
    mix(0.4, 0.8, uv.y)
  );
  gl_FragColor = vec4(color, 1.0);
}
