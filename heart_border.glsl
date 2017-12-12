vec3 gradient(vec2 uv) {
  const vec3 startColor = vec3(0.753, 0, 0);
  const vec3 endColor = vec3(0.412, 0, 0.831);
  const vec2 startUV = vec2(0.2, 0.8);
  const vec2 endUV = vec2(0.8, 0.2);

  vec2 gradientVector = endUV - startUV;
  float k = dot(uv - startUV, gradientVector);
  k /= dot(gradientVector, gradientVector); // length squared
  k = clamp(k, 0.0, 1.0);
  return mix(startColor, endColor, k);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  float t = u_time;
  t *= 1.0;

  const vec2 amplitude = vec2(0.4, 0.0);

  vec3 color = gradient(uv + amplitude * sin(t));

  // TODO: heart shape
  float radius = 2.0 * distance(uv, vec2(0.5));
  if (radius < 0.7) {
    color = vec3(1, 0.761, 0.871);
  } else if (radius < 0.75) {
    color = gradient(1.0 - uv - amplitude * sin(t));
  }

  gl_FragColor = vec4(color, 1.0);
}
