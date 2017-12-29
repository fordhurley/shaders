void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  const vec3 startColor = vec3(1.0, 0.0, 0.0);
  const vec3 endColor = vec3(0.0, 0.0, 1.0);
  vec2 startUV = u_mouse;
  const vec2 endUV = vec2(1.0, 1.0);

  vec2 gradientVector = endUV - startUV;
  float k = dot(uv - startUV, gradientVector);
  k /= dot(gradientVector, gradientVector); // length squared
  k = clamp(k, 0.0, 1.0);
  vec3 color = mix(startColor, endColor, k);

  gl_FragColor = vec4(color, 1.0);
}
