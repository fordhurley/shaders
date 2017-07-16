  // The star will be centered on st=(0, 0) and extend
  // from -size to +size.
float star(vec2 st, float sharpness, float size) {
  float vert = 1.0 - pow(abs(st.x), 1.0/sharpness);
  vert = clamp(vert, 0.0, 1.0);
  float horiz = 1.0 - pow(abs(st.y), 1.0/sharpness);
  horiz = clamp(horiz, 0.0, 1.0);
  float glare = pow(vert * horiz, 1.0/size);
  glare *= sharpness;

  float alpha = clamp(glare, 0.0, 1.0);
  return alpha;
}

float map(float value, float inMin, float inMax, float outMin, float outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

vec2 map(vec2 value, float inMin, float inMax, float outMin, float outMax) {
	return vec2(
    map(value.x, inMin, inMax, outMin, outMax),
    map(value.y, inMin, inMax, outMin, outMax)
  );
}

vec2 map(vec2 value, vec2 inMin, vec2 inMax, vec2 outMin, vec2 outMax) {
	return vec2(
    map(value.x, inMin.x, inMax.x, outMin.x, outMax.x),
    map(value.y, inMin.y, inMax.y, outMin.y, outMax.y)
  );
}

void main() {
	vec2 uv = gl_FragCoord.xy/iResolution.xy;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  const float sqrt2over2 = 0.7071068;
  const mat2 rotateBy45deg = mat2(
    sqrt2over2, sqrt2over2,
    -sqrt2over2, sqrt2over2
  );
  uv *= rotateBy45deg;
  // uv = map(uv, -sqrt2over2, sqrt2over2, -1.0, 1.0);

  float brightness = star(uv, 2.0, 1.0);
  // brightness = step(0.01, brightness);

	gl_FragColor = vec4(brightness, brightness, brightness, 1.0);
  // gl_FragColor = vec4(uv.x * 0.5 + 0.5, 0.0, 0.0, 1.0);
}
