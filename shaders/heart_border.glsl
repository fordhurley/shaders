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

// http://mathworld.wolfram.com/HeartCurve.html
float heart(float theta) {
  float s = sin(theta);
  float c = cos(theta);
  return 2.0 - 2.0 * s + s * sqrt(abs(c)) / (s + 1.4);
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  float t = u_time;
  t *= 1.0;

  const vec2 amplitude = vec2(0.4, 0.0);

  vec3 color = gradient(uv + amplitude * sin(t));

  vec2 st = 5.0 * (uv - vec2(0.5));
  st.y -= 1.5;
  float radius = length(st);
  float theta = atan(st.y, st.x);
  float heartRadius = heart(theta);
  const float borderThickness = 0.15;
  if (radius < heartRadius - borderThickness) {
    color = vec3(1, 0.761, 0.871);
  } else if (radius < heartRadius) {
    color = gradient(1.0 - uv - amplitude * sin(t));
  }

  gl_FragColor = vec4(color, 1.0);
}
