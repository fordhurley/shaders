precision highp float;

  // The star will be centered on st=(0, 0) and extend
  // from -size to +size.
float star(vec2 st, float sharpness, float size) {
  vec2 star = vec2(1.0) - pow(abs(st), vec2(1.0/sharpness));
  star = clamp(star, 0.0, 1.0);
  float glare = pow(star.x * star.y, 1.0/size);
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

uniform vec2 u_resolution;

void main() {
	vec2 uv = gl_FragCoord.xy/u_resolution.xy;
  uv = map(uv, 0.0, 1.0, -1.0, 1.0);

  const float sqrt2over2 = 0.7071068;
  const mat2 rotateBy45deg = mat2(
    sqrt2over2, sqrt2over2,
    -sqrt2over2, sqrt2over2
  );
  uv *= rotateBy45deg;

  float brightness = star(uv, 6.0, 1.0);
  // brightness = step(0.5, brightness);

	gl_FragColor = vec4(brightness, brightness, brightness, 1.0);
  // gl_FragColor = vec4(uv.x * 0.5 + 0.5, 0.0, 0.0, 1.0);
}
