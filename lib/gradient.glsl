vec3 gradient(vec2 uv, vec3 startColor, vec3 endColor, vec2 startUV, vec2 endUV) {
  vec2 gradientVector = endUV - startUV;
  float k = dot(uv - startUV, gradientVector);
  k /= dot(gradientVector, gradientVector); // length squared
  k = clamp(k, 0.0, 1.0);
  return mix(startColor, endColor, k);
}

#pragma glslify: export(gradient)
